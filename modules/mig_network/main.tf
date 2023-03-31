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

/*****************
*** Create VPC ***
******************/
module "mig_vpc" {
  source  = "terraform-google-modules/network/google"
  version = "~> 6.0"

  project_id   = var.project_id
  network_name = format("vpc-%s", var.network_name)
  routing_mode = "GLOBAL"

  subnets = [
    {
      subnet_name   = format("subnet-%s", var.subnet_name)
      subnet_ip     = var.subnet_ip
      subnet_region = var.subnet_region
    }
  ]
}

/***********************
*** Create Cloud NAT ***
************************/

module "cloud-nat" {
  source        = "terraform-google-modules/cloud-nat/google"
  version       = "~> 1.2"
  create_router = true
  project_id    = var.project_id
  region        = var.region                  #!TODO
  network       = module.mig_vpc.network_name #!TODO
  router        = format("router-%s", var.network_name)
  name          = format("nat-%s", var.network_name)
}

/*********************************************************************************
**** Firewall rule to allow incoming ssh connections from Google IAP servers. ****
**********************************************************************************/
resource "google_compute_firewall" "inbound-ip-ssh" {
  name    = "allow-ssh-iap"
  project = var.project_id
  network = module.mig_vpc.network_name #!TODO

  direction = "INGRESS"
  allow {
    protocol = "tcp"
    ports    = ["22", "8080"] # SSH port and Jenkins port
  }
  source_ranges = [
    "35.235.240.0/20"
  ]
  source_tags = ["allow-ssh-iap"]
}
