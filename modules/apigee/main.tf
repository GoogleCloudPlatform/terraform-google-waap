# Apigee Org, Instance, EnvGroup, Env setup
# https://cloud.google.com/apigee/docs/api-platform/get-started/install-cli#create-org
# https://cloud.google.com/apigee/docs/api-platform/get-started/install-cli#runtime-instance
# https://cloud.google.com/apigee/docs/api-platform/get-started/install-cli#create-environment
module "apigee_core" {
  source = "github.com/apigee/terraform-modules//modules/apigee-x-core"

  project_id          = var.project_id
  network             = var.network_id
  billing_type        = var.billing_typea
  ax_region           = var.ax_region
  apigee_instances    = var.apigee_instances
  apigee_environments = var.apigee_environments
  apigee_envgroups    = var.apigee_envgroups
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
  psc_target_service    = module.apigee_core.instance_service_attachments[each.value.region]
  lifecycle {
    create_before_destroy = true
  }
}

module "psc_lb" {
  source = "github.com/apigee/terraform-modules//modules/nb-psc-l7xlb"

  project_id              = var.project_id
  name                    = "apigee-xlb-psc"
  network                 = var.network_id
#   psc_service_attachments = { (local.region) = module.apigee_core.instance_service_attachments[local.region] }
  ssl_certificate         = var.ssl_certificate
  external_ip             = var.external_ip
  psc_negs                = [for _, psc_neg in google_compute_region_network_endpoint_group.psc_neg : psc_neg.id]
}