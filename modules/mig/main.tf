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

resource "google_service_account" "vm_sa" {
  project    = var.project_id
  account_id = var.service_account
}

resource "google_project_iam_member" "sa_roles" {
  for_each = toset(var.roles)

  project = var.project_id
  role    = each.key
  member  = "serviceAccount:${google_service_account.vm_sa.email}"
}

module "instance_template" {
  source  = "terraform-google-modules/vm/google//modules/instance_template"
  version = "~> 8.0.0"

  project_id   = var.project_id
  name_prefix  = var.name_prefix
  machine_type = var.machine_type

  source_image         = var.source_image
  source_image_project = var.source_image_project
  disk_size_gb         = var.disk_size_gb
  disk_type            = var.disk_type
  auto_delete          = var.disk_auto_delete

  startup_script = var.startup_script

  network    = var.network
  subnetwork = "https://www.googleapis.com/compute/v1/projects/${var.project_id}/regions/${var.region}/subnetworks/${var.subnetwork}"
  service_account = {
    email  = google_service_account.vm_sa.email
    scopes = var.scopes
  }

  tags = var.tags
}

module "mig" {
  source  = "terraform-google-modules/vm/google//modules/mig"
  version = "~> 8.0.0"

  project_id = var.project_id
  mig_name   = var.mig_name
  hostname   = "${var.mig_name}-vm"
  region     = var.region

  instance_template = module.instance_template.self_link
  target_size       = var.target_size

  named_ports = [{
    name = var.port_name
    port = var.backend_port
  }]

  update_policy = [{
    type                         = "PROACTIVE"
    instance_redistribution_type = "PROACTIVE"
    replacement_method           = "SUBSTITUTE"
    minimal_action               = "REPLACE"
    max_surge_fixed              = var.max_surge_fixed
    max_unavailable_fixed        = var.max_unavailable_fixed
    max_unavailable_percent      = null
    max_surge_percent            = null
    min_ready_sec                = 100
  }]
}
