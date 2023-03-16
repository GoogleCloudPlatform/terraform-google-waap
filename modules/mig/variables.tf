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

variable "zone" {
  description = "Zone for managed instance groups."
  type        = string 
  default     = "us-central1-f"
}

## VM Service Account ##
variable "service_account_id" {
  description = "The account ID used to generate the virtual machine service account."
  type        = string 
  default     = ""
}

variable "service_account_roles" {
  description = "Permissions to be added to the created service account."
  type        = list(string)
  default     = []
}

## VM Template ##
variable "name_prefix" {
  description = "Name prefix for the instance template"
  type        = string
  default     = "vm-template-"
}

variable "machine_type" {
  description = "Machine type to create, e.g. n1-standard-1"
  type        = string
  default     = "n1-standard-1"
}

variable "tags" {
  description = "Network tags, provided as a list"
  type        = list(string)
  default     = []
}

variable "source_image" {
  description = "Image used for compute VMs."
  default     = "debian-cloud/debian-11"
}

variable "disk_auto_delete" {
  description = "Whether or not the disk should be auto-deleted."
  type        = bool 
  default     = true
}

variable "disk_type" {
  description = "The GCE disk type. Can be either pd-ssd, local-ssd, pd-balanced or pd-standard."
  type        = string  
  default     = "pd-standard"
}

variable "disk_size_gb" {
  description = "The size of the image in gigabytes. If not specified, it will inherit the size of its base image."
  type        = string
  default     = "100"
}

variable "disk_mode" {
  description = "The mode in which to attach this disk, either READ_WRITE or READ_ONLY."
  default     = "READ_WRITE"
}

variable "service_account_scopes" {
  description = "List of scopes for the instance template service account"
  type        = list
  default     = [] 
}

variable "startup_script" {
  description = "value"
  type = string
  default = ""
}

## Network ##
variable "network" {
  description = "Name of the network to deploy instances to."
  type        = string 
  default     = "default"
}

variable "subnetwork" {
  description = "The subnetwork to deploy to"
  type        = string 
  default     = "default"
}

## Managed Instance Group ##
variable "mig_name" {
  description = "Name of the managed instance group."
  type        = string
  default     = ""
}

variable "base_instance_name" {
  description = "The base instance name to use for instances in this group."
  type        = string
  default     = "backend-vm" 
}