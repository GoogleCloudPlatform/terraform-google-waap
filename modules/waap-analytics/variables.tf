/**
 * Copyright 2023 Google LLC
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
  description = "GCP Project ID in which analytics resources will be created"
  type        = string
}

variable "log_sink_name" {
  description = "Name of BigQuery log sink"
  type        = string
  default     = "WAAP_log_sink"
}

variable "ca_policy_name" {
  description = "Name of Cloud Armor Security Policy resource"
  type        = string
}

variable "dataset_name" {
  description = "Name of BigQuery dataset where WAAP analytics will be stored"
  type        = string
  default     = "waap_analytics"
}

variable "sa_name" {
  description = "Name of service account with BigQuery access to be used by Looker for dashboarding"
  type        = string
  default     = "waap-bq-sa"
}
