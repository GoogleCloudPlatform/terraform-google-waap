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
  default       = ""
}

## Source Geography ##

variable "src_geo_enable" {
  description   = "Enable geolocation rule"
  type          = bool
  default       = false
}

variable "src_geo_action" {
  description   = "Defines whether the action to be performed will be allow or deny"
  type          = string
  default       = "allow"
}

variable "src_geo_priority" {
  description   = "Geolocation rule priority"
  type          = string
  default       = "1"
}

variable "src_geo_expression" {
  description   = "Textual representation of an expression in Common Expression Language syntax"
  type          = string
  default       = "US"
}

## Source IP Address ##

variable "src_ip_enable" {
  description   = "Enable Source IP Address rule"
  type          = bool
  default       = false
}

variable "src_ip_action" {
  description   = "Defines whether the action to be performed will be allow or deny"
  type          = string
  default       = "allow"
}

variable "src_ip_priority" {
  description   = "Source IP Address rule priority"
  type          = string
  default       = "1"
}

variable "src_ip_ranges" {
  description   = "Ranges of IPs used in the rule."
  type          = list(string)
  default       = ["35.191.0.0/16"]
}