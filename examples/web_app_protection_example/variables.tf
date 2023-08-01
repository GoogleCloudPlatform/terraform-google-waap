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

variable "backend_port" {
  description = "Port used by the backend"
  type        = number
  default     = 80
}

variable "enable_cdn" {
  description = "Enable or disable the CDN feature"
  type        = bool
  default     = true
}

variable "networks" {
  description = "Map of network and subnet configurations"
  type        = map(object({
    cnat_region  = string
    network_name = string
    subnets = list(object({
      subnet_name   = string
      subnet_ip     = string
      subnet_region = string
    }))
  }))
  default = {
    network1 = {
      network_name = "vpc-webapp-r1"
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
/***********************
** Variables Region 1 **
************************/

variable "region_r1" {
  description = "Region one in which to create resources."
  type        = string
  default     = "us-central1"
}

variable "zone_r1" {
  description = "Zone one in which to create resources."
  type        = string
  default     = "us-central1-b"
}

variable "name_prefix_r1" {
  description = "Name prefix for the instance template"
  type        = string
  default     = "vm-template-"
}

variable "machine_type_r1" {
  description = "Machine type to create, e.g. n1-standard-1"
  type        = string
  default     = "e2-small"
}

variable "tags_r1" {
  description = "Network tags, provided as a list"
  type        = list(string)
  default     = ["backend-r1", "lb-web-hc"]
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
  default     = "sa-backend-vm-r1"
}

variable "service_account_roles_r1" {
  description = "Permissions to be added to the created service account."
  type        = list(string)
  default     = ["roles/monitoring.metricWriter", "roles/logging.logWriter"]
}

variable "service_account_scopes_r1" {
  description = "List of scopes for the instance template service account"
  type        = list(any)
  default     = ["logging-write", "monitoring-write", "cloud-platform"]
}

variable "mig_name_r1" {
  description = "Name of the managed instance group."
  type        = string
  default     = "mig-backend-r1"
}

variable "base_instance_name_r1" {
  description = "The base instance name to use for instances in this group."
  type        = string
  default     = "mig-backend-r1-vm"
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
  description = "Region two in which to create resources."
  type        = string
  default     = "us-east1"
}

variable "zone_r2" {
  description = "Zone two in which to create resources."
  type        = string
  default     = "us-east1-b"
}

variable "name_prefix_r2" {
  description = "Name prefix for the instance template"
  type        = string
  default     = "vm-template-"
}

variable "machine_type_r2" {
  description = "Machine type to create, e.g. n1-standard-1"
  type        = string
  default     = "e2-small"
}

variable "tags_r2" {
  description = "Network tags, provided as a list"
  type        = list(string)
  default     = ["backend-r2", "lb-web-hc"]
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
  default     = "sa-backend-vm-r2"
}

variable "service_account_roles_r2" {
  description = "Permissions to be added to the created service account."
  type        = list(any)
  default     = ["roles/monitoring.metricWriter", "roles/logging.logWriter"]
}

variable "service_account_scopes_r2" {
  description = "List of scopes for the instance template service account"
  type        = list(any)
  default     = ["logging-write", "monitoring-write", "cloud-platform"]
}

variable "mig_name_r2" {
  description = "Name of the managed instance group."
  type        = string
  default     = "mig-backend-r2"
}

variable "base_instance_name_r2" {
  description = "The base instance name to use for instances in this group."
  type        = string
  default     = "mig-backend-r2-vm"
}

variable "target_size_r2" {
  description = "The target number of running instances for this managed instance group. This value should always be explicitly set unless this resource is attached to an autoscaler, in which case it should never be set."
  type        = number
  default     = 1
}
