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
locals {
  environment = "dev"
}

module "network_mig_r1" {
    source = "../../../../modules/mig"

    project_id    = var.project_id
    region        = var.region_r1
    network_name  = var.network_name_r1
    subnet_name   = var.subnet_name_r1
    subnet_ip     = var.subnet_ip_r1
    subnet_region = var.subnet_region_r1
}

module "network_mig_r2" {
    source = "../../../../modules/mig"

    project_id    = var.project_id
    region        = var.region_r2
    network_name  = var.network_name_r2
    subnet_name   = var.subnet_name_r2
    subnet_ip     = var.subnet_ip_r2
    subnet_region = var.subnet_region_r2
}