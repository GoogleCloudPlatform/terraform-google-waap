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

resource "google_compute_security_policy" "policy" {
  project     = var.project_id

  name        = var.name
  description = var.description
  type        = var.type
  
  # -----------------------------------------------------------------------------------------
  # Source Geography
  # -----------------------------------------------------------------------------------------
  dynamic "rule" {
    count                   = var.src_geo_enable ? 1 : 0
    content {
        action              = var.src_geo_action
        priority            = var.src_geo_priority
        description         = "${var.src_geo_action} specific Regions"
        match {
          expr {
            expression      = var.src_geo_expression
          }
        }
    }
  }
  # -----------------------------------------------------------------------------------------
  # Source IP Address
  # -----------------------------------------------------------------------------------------
  dynamic "rule" {
    count                   = var.src_ip_enable ? 1 : 0
    content {
        action              = var.src_ip_action
        priority            = var.src_ip_priority
        description         = "${var.src_ip_action} specific Regions"
        match {
          versioned_expr    = "SRC_IPS_V1"
          config {
            src_ip_ranges   = var.src_ip_ranges
          }
        }
    }
  }
}