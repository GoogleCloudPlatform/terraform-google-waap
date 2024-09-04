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

module "log_export" {
  source  = "terraform-google-modules/log-export/google"
  version = "~> 9.0.0"

  destination_uri = module.destination.destination_uri
  filter          = "resource.type:(http_load_balancer) AND jsonPayload.enforcedSecurityPolicy.name:(${var.ca_policy_name})"
  exclusions = [
    {
      name        = "Ignore",
      description = "Ignore socket and assets",
      filter      = "httpRequest.requestUrl =~ \"(socket.io|.js|.css)\"",
      disabled    = false
    }
  ]
  log_sink_name          = var.log_sink_name
  parent_resource_id     = var.project_id
  parent_resource_type   = "project"
  unique_writer_identity = true
}

module "destination" {
  source  = "terraform-google-modules/log-export/google//modules/bigquery"
  version = "~> 9.0.0"

  project_id               = var.project_id
  dataset_name             = var.dataset_name
  log_sink_writer_identity = module.log_export.writer_identity
}

resource "google_service_account" "waap_analytics_sa" {
  project      = var.project_id
  account_id   = var.sa_name
  display_name = "Looker Service account for WAAP dashboarding"
}

resource "google_bigquery_dataset_iam_member" "editor" {
  project    = var.project_id
  dataset_id = module.destination.resource_name
  role       = "roles/bigquery.dataEditor"
  member     = "serviceAccount:${google_service_account.waap_analytics_sa.email}"
}
