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

## VM Service Account ##
variable "service_account" {
  description = "The account ID used to generate the virtual machine service account."
  type        = string
  default     = ""
}

variable "roles" {
  description = "Permissions to be added to the created service account."
  type        = list(any)
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
variable "source_image" {
  description = "Source disk image. If neither source_image nor source_image_family is specified, defaults to the latest public CentOS image."
  type        = string
  default     = ""
}

variable "source_image_project" {
  description = "Project where the source image comes from. The default project contains CentOS images.	"
  type        = string
  default     = ""
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

variable "scopes" {
  description = "List of scopes for the instance template service account"
  type        = list(any)
  default     = []
}

variable "startup_script" {
  description = "VM startup script."
  type        = string
  default     = ""
}

variable "tags" {
  description = "Network tags, provided as a list"
  type        = list(string)
  default     = []
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

variable "region" {
  description = "Region for cloud resources."
  type        = string
  default     = "us-central1"
}

variable "target_size" {
  description = "The target number of running instances for this managed instance group. This value should always be explicitly set unless this resource is attached to an autoscaler, in which case it should never be set."
  type        = number
  default     = 1
}

variable "max_surge_fixed" {
  description = "The maximum number of instances that can be created above the specified targetSize during the update process."
  type        = number
}

variable "max_unavailable_fixed" {
  description = "The maximum number of instances that can be unavailable during the update process."
  type        = number
}

variable "port_name" {
  description = "The name of the port."
  type        = string
  default     = "http"
}

variable "backend_port" {
  description = "The backend port number."
  type        = number
  default     = 80
}
