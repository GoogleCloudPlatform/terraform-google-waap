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

# Apigee Org, Instance, EnvGroup, Env setup
# https://cloud.google.com/apigee/docs/api-platform/get-started/install-cli#create-org
# https://cloud.google.com/apigee/docs/api-platform/get-started/install-cli#runtime-instance
# https://cloud.google.com/apigee/docs/api-platform/get-started/install-cli#create-environment
# module "apigee_core" {
#   source = "github.com/apigee/terraform-modules//modules/apigee-x-core?ref=v0.12.0"

#   project_id          = var.project_id
#   network             = var.network_id
#   billing_type        = var.billing_type
#   ax_region           = var.ax_region
#   apigee_instances    = var.apigee_instances
#   apigee_environments = var.apigee_environments
#   apigee_envgroups    = var.apigee_envgroups
# }

resource "google_project_service_identity" "apigee_sa" {
  provider = google-beta
  project  = var.project_id
  service  = "apigee.googleapis.com"
}

module "apigee" {
  source     = "github.com/GoogleCloudPlatform/cloud-foundation-fabric//modules/apigee?ref=daily-2022.12.20"
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
  envgroups = var.apigee_envgroups
  # {
  #   test = ["test.example.com"]
  #   prod = ["prod.example.com"]
  # }
  environments = var.apigee_environments
  # {
  #   apis-test = {
  #     display_name = "APIs test"
  #     description  = "APIs Test"
  #     envgroups    = ["test"]
  #   }
  #   apis-prod = {
  #     display_name = "APIs prod"
  #     description  = "APIs prod"
  #     envgroups    = ["prod"]
  #     iam = {
  #       "roles/viewer" = ["group:devops@myorg.com"]
  #     }
  #   }
  # }
  instances = { for k, v in var.apigee_instances : k => {
    region                   = v.region
    environments             = v.environments
    psa_ip_cidr_range        = v.psa_ip_cidr_range
    disk_encryption_key_name = module.apigee_instance_kms[k].keys["inst-disk"]
  } }

  # var.apigee_instances
  # {
  #   instance-test-ew1 = {
  #     region            = "europe-west1"
  #     environments      = ["apis-test"]
  #     psa_ip_cidr_range = "10.0.4.0/22"
  #   }
  #   instance-prod-ew3 = {
  #     region            = "europe-west3"
  #     environments      = ["apis-prod"]
  #     psa_ip_cidr_range = "10.0.5.0/22"
  #   }
  # }
  endpoint_attachments = var.apigee_endpoint_attachments
  # {
  #   endpoint-backend-1 = {
  #     region             = "europe-west1"
  #     service_attachment = "projects/my-project-1/serviceAttachments/gkebackend1"
  #   }
  #   endpoint-backend-2 = {
  #     region             = "europe-west1"
  #     service_attachment = "projects/my-project-2/serviceAttachments/gkebackend2"
  #   }
  # }
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
  location           = each.value.region
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
  name                  = "apigee-psc-neg-${each.value.region}"
  region                = each.value.region
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
