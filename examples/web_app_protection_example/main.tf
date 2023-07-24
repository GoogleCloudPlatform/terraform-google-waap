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

## ---------------------------------------------------------------------------------------------------------------------
## STARTUP SCRIPT GCE
## Installs and configures the application in the backends.
## ---------------------------------------------------------------------------------------------------------------------

data "template_file" "startup_script" {
  template = file("./scripts/startup-script.sh")
}

## ---------------------------------------------------------------------------------------------------------------------
## NETWORKS
## Modules created for configuring networks used in two different regions...
## ---------------------------------------------------------------------------------------------------------------------

module "network_mig_r1" {
  source = "../../modules/mig-network"

  project_id    = var.project_id
  region        = var.region_r1
  network_name  = var.network_name_r1
  subnet_name   = var.subnet_name_r1
  subnet_ip     = var.subnet_ip_r1
  subnet_region = var.subnet_region_r1
}

module "network_mig_r2" {
  source = "../../modules/mig-network"

  project_id    = var.project_id
  region        = var.region_r2
  network_name  = var.network_name_r2
  subnet_name   = var.subnet_name_r2
  subnet_ip     = var.subnet_ip_r2
  subnet_region = var.subnet_region_r2
}

## ---------------------------------------------------------------------------------------------------------------------
## MIGs
## Creation of templates and configuration of MIGs.
## ---------------------------------------------------------------------------------------------------------------------

module "mig_r1" {
  source = "../../modules/mig"

  project_id   = var.project_id
  region       = var.region_r1
  name_prefix  = var.name_prefix_r1
  machine_type = var.machine_type_r1
  tags         = var.tags_r1

  source_image = var.source_image_r1
  disk_size_gb = var.disk_size_gb_r1

  service_account = var.service_account_id_r1
  roles           = var.service_account_roles_r1
  scopes          = var.service_account_scopes_r1

  startup_script = data.template_file.startup_script.rendered

  network    = var.network_name_r1
  subnetwork = var.subnet_name_r1

  mig_name           = var.mig_name_r1
  base_instance_name = var.base_instance_name_r1
  zone               = var.zone_r1

  target_size = var.target_size_r1

  depends_on = [
    module.network_mig_r1
  ]
}

module "mig_r2" {
  source = "../../modules/mig"

  project_id   = var.project_id
  region       = var.region_r2
  name_prefix  = var.name_prefix_r2
  machine_type = var.machine_type_r2
  tags         = var.tags_r2

  source_image = var.source_image_r2
  disk_size_gb = var.disk_size_gb_r2

  service_account = var.service_account_id_r2
  roles           = var.service_account_roles_r2
  scopes          = var.service_account_scopes_r2

  startup_script = data.template_file.startup_script.rendered

  network    = var.network_name_r2
  subnetwork = var.subnet_name_r2

  mig_name           = var.mig_name_r2
  base_instance_name = var.base_instance_name_r2
  zone               = var.zone_r2

  target_size = var.target_size_r2

  depends_on = [
    module.network_mig_r2
  ]
}

## ---------------------------------------------------------------------------------------------------------------------
## RECAPTCHA
## Score Recaptcha Configuration.
## ---------------------------------------------------------------------------------------------------------------------

resource "google_recaptcha_enterprise_key" "primary" {
  display_name = "web_recaptcha"
  project      = var.project_id

  testing_options {
    testing_score = 0.5
  }

  web_settings {
    integration_type  = "SCORE"
    allow_all_domains = true
    allow_amp_traffic = false
  }
}

resource "random_id" "suffix" {
  byte_length = 4
}

## ---------------------------------------------------------------------------------------------------------------------
## CLOUD ARMOR
## Backend Policy configuration with owasp rules.
## ---------------------------------------------------------------------------------------------------------------------

resource "google_compute_security_policy" "edge_policy" {
  project     = var.project_id
  name        = "edge-policy-${random_id.suffix.hex}"
  type        = "CLOUD_ARMOR_EDGE"
  description = "Edge Security Policy"

  rule {
    action      = "allow"
    description = "Default rule, higher priority overrides it"
    priority    = 2147483647
    match {
      versioned_expr = "SRC_IPS_V1"
      config {
        src_ip_ranges = ["*"]
      }
    }
  }

  rule {
    action      = "deny(403)"
    description = "Deny Specific IP address"
    priority    = 7000

    match {
      versioned_expr = "SRC_IPS_V1"
      config {
        src_ip_ranges = ["85.172.66.254/32"]
      }
    }
  }

  rule {
    action      = "deny(403)"
    priority    = 7005
    description = "Deny Specific Region"
    match {
      expr {
        expression = "origin.region_code == 'CH'"
      }
    }
  }
  lifecycle {
    create_before_destroy = true
  }
}

module "backend_policy" {
  source  = "GoogleCloudPlatform/cloud-armor/google"
  version = "0.3.0"

  project_id                           = var.project_id
  name                                 = "backend-policy-${random_id.suffix.hex}"
  description                          = "Backend Security Policy"
  default_rule_action                  = "allow"
  type                                 = "CLOUD_ARMOR"
  layer_7_ddos_defense_enable          = true
  layer_7_ddos_defense_rule_visibility = "STANDARD"

  recaptcha_redirect_site_key = google_recaptcha_enterprise_key.primary.name

  pre_configured_rules = {
    "sqli_sensitivity_level_1" = {
      action          = "deny(403)"
      priority        = 9000
      description     = "Block SQL Injection"
      target_rule_set = "sqli-v33-stable"
      rate_limit_options = {
        rate_limit_http_request_count        = 100
        rate_limit_http_request_interval_sec = 10
        ban_duration_sec                     = 60
      }
    }

    "xss-stable_level_1" = {
      action            = "deny(403)"
      priority          = 9005
      description       = "Block XSS"
      target_rule_set   = "xss-v33-stable"
      sensitivity_level = 1
      rate_limit_options = {
        rate_limit_http_request_count        = 100
        rate_limit_http_request_interval_sec = 10
        ban_duration_sec                     = 60
      }
    }

    "lfi-stable_level_1" = {
      action            = "deny(403)"
      priority          = 9010
      description       = "Block Local File Inclusion"
      target_rule_set   = "lfi-v33-stable"
      sensitivity_level = 1
      rate_limit_options = {
        rate_limit_http_request_count        = 100
        rate_limit_http_request_interval_sec = 10
        ban_duration_sec                     = 60
      }
    }

    "rfi-stable_level_1" = {
      action            = "deny(403)"
      priority          = 9015
      description       = "Block Remote File Inclusion"
      target_rule_set   = "rfi-v33-stable"
      sensitivity_level = 1
      rate_limit_options = {
        rate_limit_http_request_count        = 100
        rate_limit_http_request_interval_sec = 10
        ban_duration_sec                     = 60
      }
    }

    "methodenforcement-stable_level_1" = {
      action            = "deny(403)"
      priority          = 9020
      description       = "Block Method Enforcement"
      target_rule_set   = "methodenforcement-v33-stable"
      sensitivity_level = 1
      rate_limit_options = {
        rate_limit_http_request_count        = 100
        rate_limit_http_request_interval_sec = 10
        ban_duration_sec                     = 60
      }
    }

    "rce-stable_level_1" = {
      action            = "deny(403)"
      priority          = 9025
      description       = "Block Remote Code Execution"
      target_rule_set   = "rce-v33-stable"
      sensitivity_level = 1
      rate_limit_options = {
        rate_limit_http_request_count        = 100
        rate_limit_http_request_interval_sec = 10
        ban_duration_sec                     = 60
      }
    }

    "protocolattack-stable_level_1" = {
      action            = "deny(403)"
      priority          = 9030
      description       = "Block Protocol Attack"
      target_rule_set   = "protocolattack-v33-stable"
      sensitivity_level = 1
      rate_limit_options = {
        rate_limit_http_request_count        = 100
        rate_limit_http_request_interval_sec = 10
        ban_duration_sec                     = 60
      }
    }

    "scannerdetection-stable_level_1" = {
      action            = "deny(403)"
      priority          = 9035
      description       = "Block Scanner Detection"
      target_rule_set   = "scannerdetection-v33-stable"
      sensitivity_level = 1
      rate_limit_options = {
        rate_limit_http_request_count        = 100
        rate_limit_http_request_interval_sec = 10
        ban_duration_sec                     = 60
      }
    }

    "php-stable_level_1" = {
      action            = "deny(403)"
      priority          = 9040
      description       = "Block PHP Injection Attack"
      target_rule_set   = "php-v33-stable"
      sensitivity_level = 1
      rate_limit_options = {
        rate_limit_http_request_count        = 100
        rate_limit_http_request_interval_sec = 10
        ban_duration_sec                     = 60
      }
    }

    "sessionfixation-stable_level_1" = {
      action            = "deny(403)"
      priority          = 9045
      description       = "Block Session Fixation Attack"
      target_rule_set   = "sessionfixation-v33-stable"
      sensitivity_level = 1
      rate_limit_options = {
        rate_limit_http_request_count        = 100
        rate_limit_http_request_interval_sec = 10
        ban_duration_sec                     = 60
      }
    }

    "java-stable_level_1" = {
      action            = "deny(403)"
      priority          = 9050
      description       = "Block Java Attack"
      target_rule_set   = "java-v33-stable"
      sensitivity_level = 1
      rate_limit_options = {
        rate_limit_http_request_count        = 100
        rate_limit_http_request_interval_sec = 10
        ban_duration_sec                     = 60
      }
    }

    "nodejs-stable_level_1" = {
      action            = "deny(403)"
      priority          = 9055
      description       = "Block NodeJS Attack"
      target_rule_set   = "nodejs-v33-stable"
      sensitivity_level = 1
      rate_limit_options = {
        rate_limit_http_request_count        = 100
        rate_limit_http_request_interval_sec = 10
        ban_duration_sec                     = 60
      }
    }

    "cve-canary_level_1" = {
      action            = "deny(403)"
      priority          = 9060
      description       = "Fix Log4j Vulnerability"
      target_rule_set   = "cve-canary"
      sensitivity_level = 1
      rate_limit_options = {
        rate_limit_http_request_count        = 100
        rate_limit_http_request_interval_sec = 10
        ban_duration_sec                     = 60
      }
    }

    "json-sqli-canary_level_2" = {
      action            = "deny(403)"
      priority          = 9065
      description       = "JSON-based SQL injection bypass vulnerability"
      target_rule_set   = "json-sqli-canary"
      sensitivity_level = 2
      rate_limit_options = {
        rate_limit_http_request_count        = 100
        rate_limit_http_request_interval_sec = 10
        ban_duration_sec                     = 60
      }
    }
  }
}

## ---------------------------------------------------------------------------------------------------------------------
## LOAD BALANCER
## Configuration of the Load Balancer and its resources.
## ---------------------------------------------------------------------------------------------------------------------

module "lb-http" {
  source  = "GoogleCloudPlatform/lb-http/google"
  version = "9.0.0"

  name        = "lb-web-app"
  project     = var.project_id
  target_tags = concat(var.tags_r1, var.tags_r2)

  firewall_networks    = [module.network_mig_r1.network_name, module.network_mig_r2.network_name]
  firewall_projects    = [var.project_id, var.project_id]
  use_ssl_certificates = false
  ssl                  = false
  https_redirect       = false
  quic                 = true

  backends = {
    default = {

      description                     = "Web App Backend"
      protocol                        = "HTTP"
      port                            = var.backend_port
      port_name                       = "http"
      timeout_sec                     = 600
      enable_cdn                      = var.enable_cdn
      connection_draining_timeout_sec = null
      compression_mode                = "AUTOMATIC"
      security_policy                 = module.backend_policy.policy.name
      edge_security_policy            = google_compute_security_policy.edge_policy.id
      session_affinity                = null
      affinity_cookie_ttl_sec         = null
      custom_request_headers          = null
      custom_response_headers         = null

      health_check = {

        check_interval_sec  = 60
        timeout_sec         = 60
        healthy_threshold   = 2
        unhealthy_threshold = 2
        request_path        = "/"
        port                = var.backend_port
        host                = null
        logging             = false
      }

      log_config = {
        enable      = true
        sample_rate = 0.05
      }

      cdn_policy = {
        cache_mode        = "CACHE_ALL_STATIC"
        default_ttl       = 3600
        client_ttl        = 1800
        max_ttl           = 28800
        serve_while_stale = 86400
        negative_caching  = true

        negative_caching_policy = {
          code = 404
          ttl  = 60
        }

        cache_key_policy = {
          include_host          = true
          include_protocol      = true
          include_query_string  = true
          include_named_cookies = ["__next_preview_data", "__prerender_bypass"]
        }
      }

      groups = [
        {
          group                        = module.mig_r1.instance_group
          balancing_mode               = "UTILIZATION"
          capacity_scaler              = null
          description                  = null
          max_connections              = null
          max_connections_per_instance = null
          max_connections_per_endpoint = null
          max_rate                     = 10
          max_rate_per_instance        = null
          max_rate_per_endpoint        = null
          max_utilization              = 0.9
        },
        {
          group                        = module.mig_r2.instance_group
          balancing_mode               = "UTILIZATION"
          capacity_scaler              = null
          description                  = null
          max_connections              = null
          max_connections_per_instance = null
          max_connections_per_endpoint = null
          max_rate                     = 10
          max_rate_per_instance        = null
          max_rate_per_endpoint        = null
          max_utilization              = 0.9
        },
      ]

      iap_config = {
        enable               = false
        oauth2_client_id     = ""
        oauth2_client_secret = ""
      }
    }
  }
}
## ---------------------------------------------------------------------------------------------------------------------
## MONITORING
## Dashboard
## ---------------------------------------------------------------------------------------------------------------------

resource "google_monitoring_dashboard" "dashboard" {
  dashboard_json = file("./scripts/dashboard.json")
  project        = var.project_id
}

locals {
  policies = {
    "sql_injection"           = "jsonPayload.enforcedSecurityPolicy.preconfiguredExprIds=~\"sqli\" AND jsonPayload.enforcedSecurityPolicy.preconfiguredExprIds!=\"owasp-crs-id942550-sqli\""
    "cross_site_scripting"    = "jsonPayload.enforcedSecurityPolicy.preconfiguredExprIds=~\"xss\""
    "local_file_inclusion"    = "jsonPayload.enforcedSecurityPolicy.preconfiguredExprIds=~\"lfi\""
    "remote_code_execution"   = "jsonPayload.enforcedSecurityPolicy.preconfiguredExprIds=~\"rce\""
    "remote_file_inclusion"   = "jsonPayload.enforcedSecurityPolicy.preconfiguredExprIds=~\"rfi\""
    "method_enforcement"      = "jsonPayload.enforcedSecurityPolicy.preconfiguredExprIds=~\"methodenforcement\""
    "scanner_detection"       = "jsonPayload.enforcedSecurityPolicy.preconfiguredExprIds=~\"scannerdetection\""
    "protocol_attack"         = "jsonPayload.enforcedSecurityPolicy.preconfiguredExprIds=~\"protocolattack\""
    "php_injection_attack"    = "jsonPayload.enforcedSecurityPolicy.preconfiguredExprIds=~\"php\""
    "session_fixation_attack" = "jsonPayload.enforcedSecurityPolicy.preconfiguredExprIds=~\"sessionfixation\""
    "java_attack"             = "jsonPayload.enforcedSecurityPolicy.preconfiguredExprIds=~\"java\""
    "nodejs_attack"           = "jsonPayload.enforcedSecurityPolicy.preconfiguredExprIds=~\"nodejs\""
    "log4j_attack"            = "jsonPayload.enforcedSecurityPolicy.preconfiguredExprIds=~\"cve\""
    "json_sql_injection"      = "jsonPayload.enforcedSecurityPolicy.preconfiguredExprIds=~\"owasp-crs-id942550-sqli\""
  }
}

resource "google_logging_metric" "logging_metric" {
  for_each = local.policies
  project  = var.project_id

  name   = "${each.key}/metric"
  filter = each.value
  metric_descriptor {
    metric_kind = "DELTA"
    value_type  = "INT64"

    labels {
      key        = "signature_id"
      value_type = "STRING"
    }
  }
  label_extractors = {
    "signature_id" = "EXTRACT(jsonPayload.enforcedSecurityPolicy.preconfiguredExprIds)"
  }
}
