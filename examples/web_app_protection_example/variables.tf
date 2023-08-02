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

variable "project_id" {
  description = "Google Project ID"
  type        = string
  default     = ""
}

variable "networks" {
  description = "Map of network and subnet configurations"
  type        = map(object({
    network_name = string
    cnat_region  = string
    subnets = list(object({
      subnet_name   = string
      subnet_ip     = string
      subnet_region = string
    }))
  }))
  default = {
    network1 = {
      network_name = "vpc-webapp-r1"
      cnat_region  = "us-central1"
      subnets = [
        {
          subnet_name   = "webapp-r1-subnet01"
          subnet_ip     = "10.0.16.0/24"
          subnet_region = "us-central1"
        },
        {
          subnet_name   = "webapp-r1-subnet02"
          subnet_ip     = "10.0.18.0/24"
          subnet_region = "us-west1"
        },
      ]
    },
    network2 = {
      network_name = "vpc-webapp-r2"
      cnat_region  = "us-east1"
      subnets = [
        {
          subnet_name   = "webapp-r2-subnet01"
          subnet_ip     = "10.0.32.0/24"
          subnet_region = "us-east1"
        },
        {
          subnet_name   = "webapp-r2-subnet02"
          subnet_ip     = "10.0.34.0/24"
          subnet_region = "us-east4"
        },
      ]
    },
  }
}
