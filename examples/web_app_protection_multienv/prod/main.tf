/**
 * Copyright 2023 Google LLC
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

locals {
  env = "prod"
}

module "prod_env" {
  source     = "../../web_app_protection_multienv"
  project_id = var.project_id
  env        = local.env

  /*************************
  *** Region 1 Variables ***
  **************************/
  region_r1        = "us-central1"
  zone_r1          = "us-central1-b"
  network_name_r1  = "webapp-${local.env}-r1" # prefix vpc
  subnet_name_r1   = "webapp-${local.env}-r1" # prefix subnet
  subnet_ip_r1     = "10.0.16.0/24"
  subnet_region_r1 = "us-central1"

  name_prefix_r1  = "vm-template-${local.env}-"
  machine_type_r1 = "e2-small"
  tags_r1         = ["backend-${local.env}-r1"]

  source_image_r1 = "debian-cloud/debian-11"
  disk_size_gb_r1 = "100"

  service_account_id_r1     = "sa-backend-${local.env}-vm-r1"
  service_account_roles_r1  = ["roles/monitoring.metricWriter", "roles/logging.logWriter"]
  service_account_scopes_r1 = ["logging-write", "monitoring-write", "cloud-platform"]

  mig_name_r1           = "mig-backend-${local.env}-r1"
  base_instance_name_r1 = "mig-backend-${local.env}-r1-vm"
  target_size_r1        = 1

  /*************************
  *** Region 2 Variables ***
  **************************/

  region_r2        = "us-east1"
  zone_r2          = "us-east1-b"
  network_name_r2  = "webapp-r2" # prefix vpc
  subnet_name_r2   = "webapp-r2" # prefix subnet
  subnet_ip_r2     = "10.0.32.0/24"
  subnet_region_r2 = "us-east1"

  name_prefix_r2  = "vm-template-${local.env}-"
  machine_type_r2 = "e2-small"
  tags_r2         = ["backend-${local.env}-r2"]

  source_image_r2 = "debian-cloud/debian-11"
  disk_size_gb_r2 = "100"

  service_account_id_r2     = "sa-backend-${local.env}-vm-r2"
  service_account_roles_r2  = ["roles/monitoring.metricWriter", "roles/logging.logWriter"]
  service_account_scopes_r2 = ["logging-write", "monitoring-write", "cloud-platform"]

  mig_name_r2           = "mig-backend-${local.env}-r2"
  base_instance_name_r2 = "mig-backend-${local.env}-r2-vm"
  target_size_r2        = 1

  cloud_armor_pre_configured_rules = {}
  cloud_armor_security_rules       = {}
  cloud_armor_custom_rules         = {}
}
