/*********************************
** Juice Shop Example using MIG **
**********************************/

locals {
  business_unit = "business_unit_1"
  environment   = "development"
}

module "base_mig" {
    source = "../../modules/env_base"

    project_id      = var.project_id
    region          = var.region
    network_name    = var.network_name
    subnet_name     = var.subnet_name
    subnet_ip       = var.subnet_ip
    subnet_region   = var.subnet_region
}