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
  project     = var.project_id
  account_id  = var.service_account
}

resource "google_project_iam_member" "sa_roles" {
  for_each = var.roles

  project  = var.project_id
  role     = each.key
  member   = "serviceAccount:${google_service_account.vm_sa.email}"
}

resource "google_compute_instance_template" "vm_template" {
  project                 = var.project_id

  name_prefix             = var.name_prefix
  machine_type            = var.machine_type
  region                  = var.region
  tags                    = var.tags

  disk {
    boot                  = true
    type                  = "PERSISTENT"
    source_image          = var.source_image
    auto_delete           = var.disk_auto_delete
    disk_type             = var.disk_type
    disk_size_gb          = var.disk_size_gb
    mode                  = var.disk_mode 
  }
  
  service_account {
    email                 = google_service_account.vm_sa.email
    scopes                = var.service_account_scopes
  }

   metadata = {
    # startup-script        = "${data.template_file.ops_agent_install_script.rendered}"
    startup-script        = var.startup_script
  }

    network_interface {
      network             = var.network
      subnetwork          = "https://www.googleapis.com/compute/v1/projects/${var.project_id}/regions/${var.region}/subnetworks/${var.subnetwork}"
    }
  
  lifecycle {
    create_before_destroy = true
  }
}

resource "google_compute_instance_group_manager" "mig" {
  project                   = var.project_id

  name                      = var.mig_name == "" ? "${var.base_instance_name}-mig" : var.mig_name
  base_instance_name        = var.base_instance_name
  zone                      = var.zone
  
  version {
    instance_template       = google_compute_instance_template.vm_template.self_link
  }

  target_size               = var.target_size
}