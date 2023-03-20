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

/***********************
** Variables Region 1 **
************************/

variable "region_r1" {
  description = "Region in which to create resources"
  type        = string
  default     = ""
}

variable "zone_r1" {
  description = "value"
  type        = string
  default     = ""
}

variable "network_name_r1" {
  description = "VPC network name"
  type        = string
  default     = ""
}

variable "subnet_name_r1" {
  description = "Subnet name"
  type        = string
  default     = ""
}

variable "subnet_ip_r1" {
  description = "This is th IP of your subnet"
  type        = string
  default     = ""
}

variable "subnet_region_r1" {
  description = "Subnet Region"
  type        = string
  default     = ""
}

variable "name_prefix_r1" {
  description = "Name prefix for the instance template"
  type        = string
  default     = "" 
}

variable "machine_type_r1" {
  description = "Machine type to create, e.g. n1-standard-1"
  type        = string
  default     = ""
}

variable "tags_r1" {
  description = "Network tags, provided as a list"
  type        = list(string)
  default     = []
}

variable "source_image_r1" {
  description = "Image used for compute VMs."
  default     = "debian-cloud/debian-11"
}

variable "disk_size_gb_r1" {
  description = "The size of the image in gigabytes. If not specified, it will inherit the size of its base image."
  type        = string
  default     = "100"
}

variable "service_account_id_r1" {
  description = "The account ID used to generate the virtual machine service account."
  type        = string 
  default     = ""
}

variable "service_account_roles_r1" {
  description = "Permissions to be added to the created service account."
  type        = list(string)
  default     = []
}

variable "service_account_scopes_r1" {
  description = "List of scopes for the instance template service account"
  type        = list
  default     = [] 
}

variable "startup_script_r1" {
  description = "value"
  type = string
  default = ""
}

variable "mig_name_r1" {
  description = "Name of the managed instance group."
  type        = string
  default     = ""
}

variable "base_instance_name_r1" {
  description = "The base instance name to use for instances in this group."
  type        = string
  default     = "" 
}

variable "target_size_r1" {
  description = "The target number of running instances for this managed instance group. This value should always be explicitly set unless this resource is attached to an autoscaler, in which case it should never be set."
  type        = number
  default     = 1
}

/***********************
** Variables Region 2 **
************************/

variable "region_r2" {
  description = "Region in which to create resources"
  type        = string
  default     = ""
}

variable "zone_r2" {
  description = "value"
  type        = string
  default     = ""
}

variable "network_name_r2" {
  description = "VPC network name"
  type        = string
  default     = ""
}

variable "subnet_name_r2" {
  description = "Subnet name"
  type        = string
  default     = ""
}

variable "subnet_ip_r2" {
  description = "This is th IP of your subnet"
  type        = string
  default     = ""
}

variable "subnet_region_r2" {
  description = "Subnet Region"
  type        = string
  default     = ""
}

variable "name_prefix_r2" {
  description = "Name prefix for the instance template"
  type        = string
  default     = "" 
}

variable "machine_type_r2" {
  description = "Machine type to create, e.g. n1-standard-1"
  type        = string
  default     = ""
}

variable "tags_r2" {
  description = "Network tags, provided as a list"
  type        = list(string)
  default     = []
}

variable "source_image_r2" {
  description = "Image used for compute VMs."
  default     = "debian-cloud/debian-11"
}

variable "disk_size_gb_r2" {
  description = "The size of the image in gigabytes. If not specified, it will inherit the size of its base image."
  type        = string
  default     = "100"
}

variable "service_account_id_r2" {
  description = "The account ID used to generate the virtual machine service account."
  type        = string 
  default     = ""
}

variable "service_account_roles_r2" {
  description = "Permissions to be added to the created service account."
  type        = list
  default     = []
}

variable "service_account_scopes_r2" {
  description = "List of scopes for the instance template service account"
  type        = list
  default     = [] 
}

variable "startup_script_r2" {
  description = "value"
  type = string
  default = ""
}

variable "mig_name_r2" {
  description = "Name of the managed instance group."
  type        = string
  default     = ""
}

variable "base_instance_name_r2" {
  description = "The base instance name to use for instances in this group."
  type        = string
  default     = "" 
}

variable "target_size_r2" {
  description = "The target number of running instances for this managed instance group. This value should always be explicitly set unless this resource is attached to an autoscaler, in which case it should never be set."
  type        = number
  default     = 1
}