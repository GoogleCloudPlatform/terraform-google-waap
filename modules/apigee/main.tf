/**
 * Copyright 2022 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

resource "google_project_service_identity" "apigee_sa" {
  provider = google-beta
  project  = var.project_id
  service  = "apigee.googleapis.com"
}

module "apigee" {
  source     = "github.com/GoogleCloudPlatform/cloud-foundation-fabric//modules/apigee?ref=v24.0.0"
  project_id = var.project_id
  organization = !var.create_apigee_org ? null : {
    display_name            = var.apigee_org_name
    description             = var.apigee_org_description
    authorized_network      = var.network_id
    runtime_type            = var.runtime_type
    billing_type            = var.billing_type
    database_encryption_key = module.apigee_org_kms.keys["org-db"]
    analytics_region        = var.analytics_region
  }
  envgroups    = var.apigee_envgroups
  environments = var.apigee_environments
  instances = { for k, v in var.apigee_instances : k => {
    display_name                  = v.display_name
    description                   = v.description
    runtime_ip_cidr_range         = v.runtime_ip_cidr_range
    troubleshooting_ip_cidr_range = v.troubleshooting_ip_cidr_range
    consumer_accept_list          = v.consumer_accept_list
    disk_encryption_key           = module.apigee_instance_kms[k].keys["inst-disk"]
  } }
  endpoint_attachments = var.apigee_endpoint_attachments
  depends_on           = [google_service_networking_connection.apigee_peering]
}

module "apigee_org_kms" {
  source  = "terraform-google-modules/kms/google"
  version = "~> 2.2.1"

  project_id         = var.kms_project_id == "" ? var.project_id : var.kms_project_id
  location           = var.analytics_region
  keyring            = "apigee-${var.project_id}"
  keys               = ["org-db"]
  set_decrypters_for = ["org-db"]
  set_encrypters_for = ["org-db"]
  decrypters = [
    "serviceAccount:${google_project_service_identity.apigee_sa.email}"
  ]
  encrypters = [
    "serviceAccount:${google_project_service_identity.apigee_sa.email}"
  ]
  prevent_destroy = var.prevent_key_destroy
}

module "apigee_instance_kms" {
  for_each = var.apigee_instances
  source   = "terraform-google-modules/kms/google"
  version  = "~> 2.2.1"

  project_id         = var.kms_project_id == "" ? var.project_id : var.kms_project_id
  location           = each.key
  keyring            = "apigee-${var.project_id}-inst-${each.key}"
  keys               = ["inst-disk"]
  set_decrypters_for = ["inst-disk"]
  set_encrypters_for = ["inst-disk"]
  decrypters = [
    "serviceAccount:${google_project_service_identity.apigee_sa.email}"
  ]
  encrypters = [
    "serviceAccount:${google_project_service_identity.apigee_sa.email}"
  ]
  prevent_destroy = var.prevent_key_destroy
}

# Service Networking
# https://cloud.google.com/apigee/docs/api-platform/get-started/install-cli#service-networking
resource "google_compute_global_address" "apigee_ranges" {
  for_each      = var.psa_ranges
  project       = var.project_id
  name          = each.key
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  address       = split("/", each.value)[0]
  prefix_length = split("/", each.value)[1]
  network       = var.network_id
}

resource "google_service_networking_connection" "apigee_peering" {
  network = var.network_id
  service = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [
    for k, v in google_compute_global_address.apigee_ranges : v.name
  ]
}

resource "google_compute_network_peering_routes_config" "psa_routes" {
  project              = var.project_id
  peering              = google_service_networking_connection.apigee_peering.peering
  network              = split("/", var.network_id)[4] # grab network name from ID in format projects/{{project}}/global/networks/{{name}}
  export_custom_routes = false
  import_custom_routes = false
}

# Routing
# https://cloud.google.com/apigee/docs/api-platform/get-started/install-cli#configure-routing
resource "google_compute_region_network_endpoint_group" "psc_neg" {
  project               = var.project_id
  for_each              = var.apigee_instances
  name                  = "apigee-psc-neg-${each.key}"
  region                = each.key
  network               = var.network_id
  subnetwork            = var.subnet_id
  network_endpoint_type = "PRIVATE_SERVICE_CONNECT"
  psc_target_service    = module.apigee.service_attachments[each.key]
  lifecycle {
    create_before_destroy = true
  }
}

module "psc_lb" {
  source = "github.com/apigee/terraform-modules//modules/nb-psc-l7xlb?ref=v0.12.0"

  project_id = var.project_id
  name       = "apigee-xlb-psc"
  network    = var.network_id
  #   psc_service_attachments = { (local.region) = module.apigee_core.instance_service_attachments[local.region] }
  ssl_certificate = var.ssl_certificate
  external_ip     = var.external_ip
  psc_negs        = [for _, psc_neg in google_compute_region_network_endpoint_group.psc_neg : psc_neg.id]
}
