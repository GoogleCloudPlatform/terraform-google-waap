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

variable "region" {
  description = "Region for cloud resources."
  type        = string
  default     = "us-central1"
}

## Network ##
variable "network_name" {
  description = "Name of the network to deploy instances to."
  type        = string
  default     = "default"
}

variable "subnet_name" {
  description = "The subnetwork to deploy to"
  type        = string
  default     = "default"
}

variable "subnet_ip" {
  type    = string
  default = "10.0.16.0/24"
}

variable "subnet_region" {
  type    = string
  default = "us-central"
}
