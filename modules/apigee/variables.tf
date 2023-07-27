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

variable "apigee_org_name" {
  description = "Display name for Apigee Organization."
  type        = string
  default     = "Apigee Org"
}

variable "apigee_org_description" {
  description = "Description for Apigee Organization."
  type        = string
  default     = "Apigee Org"
}

variable "analytics_region" {
  description = "GCP region for storing Apigee analytics data (see https://cloud.google.com/apigee/docs/api-platform/get-started/install-cli)."
  type        = string
}

variable "apigee_envgroups" {
  description = "Apigee groups (NAME => [HOSTNAMES])."
  type        = map(list(string))
  default     = null
}

variable "apigee_environments" {
  description = "Apigee Environments."
  type = map(object({
    display_name    = optional(string)
    description     = optional(string, "Terraform-managed")
    deployment_type = optional(string)
    api_proxy_type  = optional(string)
    node_config = optional(object({
      min_node_count = optional(number)
      max_node_count = optional(number)
    }))
    iam       = optional(map(list(string)))
    envgroups = optional(list(string))
    regions   = optional(list(string))
  }))
  default = null
}

variable "apigee_instances" {
  description = "Apigee Instances ([REGION] => [INSTANCE])."
  type = map(object({
    display_name                  = optional(string)
    description                   = optional(string, "Terraform-managed")
    runtime_ip_cidr_range         = string
    troubleshooting_ip_cidr_range = string
    disk_encryption_key           = optional(string)
    consumer_accept_list          = optional(list(string))
  }))
  default = null
}

variable "apigee_endpoint_attachments" {
  description = "Apigee endpoint attachments (for southbound networking: https://cloud.google.com/apigee/docs/api-platform/architecture/southbound-networking-patterns-endpoints#create-the-psc-attachments)."
  type = map(object({
    region             = string
    service_attachment = string
  }))
  default = {}
}

variable "kms_project_id" {
  description = "Project ID in which to create keys for Apigee database and disk (org/instance)"
  type        = string
  default     = ""
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

variable "runtime_type" {
  description = "Apigee runtime type. Can be one of CLOUD or HYBRID."
  type        = string
  default     = "CLOUD"
}

# variable "region" {
#   description = "Region in which to create resources"
#   type = string
#   default = "us-central1"
# }

variable "create_apigee_org" {
  description = "Set to `true` to create a new Apigee org in the provided `var.project_id`; set to `false` to use the existing Apigee org in this project."
  type        = bool
  default     = true
}

variable "prevent_key_destroy" {
  description = "Prevent destroying KMS keys for Apigee Org and Instances"
  type        = bool
  default     = true
}
