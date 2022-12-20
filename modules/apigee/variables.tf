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

variable "ax_region" {
  description = "GCP region for storing Apigee analytics data (see https://cloud.google.com/apigee/docs/api-platform/get-started/install-cli)."
  type        = string
}

variable "apigee_envgroups" {
  description = "Apigee Environment Groups."
  type = map(object({
    environments = list(string)
    hostnames    = list(string)
  }))
  default = {}
}

variable "apigee_environments" {
  description = "Apigee Environment Names."
  type        = list(string)
  default     = []
}

variable "apigee_instances" {
  description = "Apigee Instances (only one for EVAL)."
  type = map(object({
    region       = string
    ip_range     = string
    environments = list(string)
  }))
  default = {}
}

variable "psa_ranges" {
  description = "Apigee Private Service Access peering ranges"
  type = object({
    apigee-range                      = string
    google-managed-services-support-1 = string
  })
  default = {
    apigee-range                      = "10.0.0.0/22"
    google-managed-services-support-1 = "10.1.0.0/28"
  }
}

variable "project_id" {
  description = "Project id (also used for the Apigee Organization)."
  type        = string
}

variable "network_id" {
  description = "VPC network ID"
  type        = string
}

variable "subnet_id" {
  description = "Apigee NEG subnet ID"
  type        = string
}

variable "ssl_certificate" {
  description = "SSL Certificate ID for Apigee Load Balancer"
  type        = string
}

variable "external_ip" {
  description = "Reserved global external IP for Apigee Load Balancer"
  type        = string
}

variable "billing_type" {
  description = "Apigee billing type. Can be one of EVALUATION, PAYG, or SUBSCRIPTION. See https://cloud.google.com/apigee/pricing"
  type        = string
  default     = "EVALUATION"
}

# variable "region" {
#   description = "Region in which to create resources"
#   type = string
#   default = "us-central1"
# }
