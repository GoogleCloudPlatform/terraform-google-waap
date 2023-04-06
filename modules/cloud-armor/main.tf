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
    for_each = var.src_geo
    content {
      action    = each.value.action
      priority  = each.value.priority
      match {
        expr {
         expression = each.value.expression 
        }
      }
      description = each.value.description
    }
  }
  # -----------------------------------------------------------------------------------------
  # Source IP Address
  # -----------------------------------------------------------------------------------------
  dynamic "rule" {
    for_each = var.src_ip
    content {
      action    = each.value.action
      priority  = each.value.priority
      match {
        versioned_expr  = each.value.versioned_expr
        config {
          src_ip_ranges = each.value.src_ip_ranges
        }
      }
      description = each.value.description
    }
  }
}