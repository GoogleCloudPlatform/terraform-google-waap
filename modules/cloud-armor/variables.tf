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
  description   = "Google Project ID"
  type          = string
}

variable "name" {
  description = "Name of the security policy."
  type        = string
}

variable "description" {
  description = "An optional description of this security policy. Max size is 2048."
  type        = string
  default     = null
}

variable "type" {
  description = "Type indicates the intended use of the security policy. Possible values are CLOUD_ARMOR and CLOUD_ARMOR_EDGE"
  type        = string
  default     = "CLOUD_ARMOR"
}

## Source Geography ##
variable "src_geo" {
  description = "Geolocation Rules"
  default = {}
  type = map(object({
    action          = string
    priority        = string
    expression      = string
    description     = string
  }))
} 

## Source IP Address ##
variable "src_ip" {
  default = {}
  type = map(object({
    action          = string
    priority        = string
    versioned_expr  = string
    src_ip_ranges   = list(string)
    description     = string
  }))
}