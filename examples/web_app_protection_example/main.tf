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
## NETWORKS
## Modules created for configuring networks used in two different regions...
## ---------------------------------------------------------------------------------------------------------------------

locals {
  network_cfg = {
    "network1" = {
      network_name = "vpc-webapp-r1"
      cnat_region  = "us-central1"
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
    "network2" = {
      network_name = "vpc-webapp-r2"
      cnat_region  = "us-east1"
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

module "network" {
  source   = "../../modules/mig-network"
  for_each = local.network_cfg

  project_id = var.project_id

  region       = each.value.cnat_region
  network_name = each.value.network_name
  subnets      = each.value.subnets
}

## ---------------------------------------------------------------------------------------------------------------------
## MIGs
## Creation of templates and configuration of MIGs.
## ---------------------------------------------------------------------------------------------------------------------

## Configuration for each Managed Instance Group
locals {
  mig_cfg = {
    "mig01" = {
      machine_type         = "e2-small"
      source_image         = "debian-11"
      source_image_project = "debian-cloud"
      disk_size            = "50"

      startup_script = file("./scripts/startup-script.sh")

      mig_name = "mig-01"
      region   = "us-central1"

      target_size           = 2
      max_surge_fixed       = 4
      max_unavailable_fixed = 0

      port_name    = "http"
      backend_port = 80

      network    = module.network["network1"].network_name
      subnetwork = module.network["network1"].subnets[0]

      service_account = "sa-mig-01"
      roles           = ["roles/monitoring.metricWriter", "roles/logging.logWriter"]
      scopes          = ["logging-write", "monitoring-write", "cloud-platform"]

      tags = ["mig-01", "lb-web-hc"]
    },
    "mig02" = {
      machine_type         = "e2-small"
      source_image         = "debian-11"
      source_image_project = "debian-cloud"
      disk_size            = "50"

      startup_script = file("./scripts/startup-script.sh")

      mig_name = "mig-02"
      region   = "us-east1"

      target_size           = 2
      max_surge_fixed       = 3
      max_unavailable_fixed = 0

      port_name    = "http"
      backend_port = 80

      network    = module.network["network2"].network_name
      subnetwork = module.network["network2"].subnets[0]

      service_account = "sa-mig-02"
      roles           = ["roles/monitoring.metricWriter", "roles/logging.logWriter"]
      scopes          = ["logging-write", "monitoring-write", "cloud-platform"]

      tags = ["mig-02", "lb-web-hc"]
    },
    # Add more settings for other MIGs if needed
  }
}
module "mig" {
  source   = "../../modules/mig"
  for_each = local.mig_cfg

  project_id = var.project_id

  machine_type         = each.value.machine_type
  source_image         = each.value.source_image
  source_image_project = each.value.source_image_project
  disk_size_gb         = each.value.disk_size

  startup_script = each.value.startup_script

  mig_name = each.value.mig_name
  region   = each.value.region

  target_size           = each.value.target_size
  max_surge_fixed       = each.value.max_surge_fixed
  max_unavailable_fixed = each.value.max_unavailable_fixed

  port_name    = each.value.port_name
  backend_port = each.value.backend_port

  network    = each.value.network
  subnetwork = each.value.subnetwork

  service_account = each.value.service_account
  roles           = each.value.roles
  scopes          = each.value.scopes

  tags = each.value.tags
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

locals {
  health_check = {
    check_interval_sec  = 60
    timeout_sec         = 60
    healthy_threshold   = 2
    unhealthy_threshold = 2
    request_path        = "/"
    port                = 80
    host                = null
    logging             = false
  }

}
module "lb-http" {
  source  = "GoogleCloudPlatform/lb-http/google"
  version = "9.0.0"

  project     = var.project_id
  name        = "lb-web-app"
  target_tags = ["lb-web-hc"]

  load_balancing_scheme = "EXTERNAL_MANAGED"

  firewall_networks    = [module.network["network1"].network_name, module.network["network2"].network_name]
  firewall_projects    = [var.project_id, var.project_id]
  use_ssl_certificates = false
  ssl                  = false
  https_redirect       = false
  quic                 = true

  create_url_map = var.url_map ? false : true
  url_map        = try(google_compute_url_map.traffic_mgmt[0].self_link, null)

  backends = {
    default = {

      description                     = "Web App Default Backend"
      protocol                        = "HTTP"
      port                            = 80
      port_name                       = "http"
      timeout_sec                     = 600
      enable_cdn                      = true
      connection_draining_timeout_sec = null
      compression_mode                = "AUTOMATIC"
      security_policy                 = module.backend_policy.policy.name
      edge_security_policy            = google_compute_security_policy.edge_policy.id
      session_affinity                = null
      affinity_cookie_ttl_sec         = null
      custom_request_headers          = null
      custom_response_headers         = null

      health_check = local.health_check
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
          group                        = module.mig["mig01"].instance_group
          balancing_mode               = "UTILIZATION"
          capacity_scaler              = null
          description                  = null
          max_connections              = null
          max_connections_per_instance = null
          max_connections_per_endpoint = null
          max_rate                     = null
          max_rate_per_instance        = null
          max_rate_per_endpoint        = null
          max_utilization              = 0.9
        },
        {
          group                        = module.mig["mig02"].instance_group
          balancing_mode               = "UTILIZATION"
          capacity_scaler              = null
          description                  = null
          max_connections              = null
          max_connections_per_instance = null
          max_connections_per_endpoint = null
          max_rate                     = null
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
    web-app01 = {

      description                     = "Web App Backend 01"
      protocol                        = "HTTP"
      port                            = 80
      port_name                       = "http"
      timeout_sec                     = 600
      enable_cdn                      = true
      connection_draining_timeout_sec = null
      compression_mode                = "AUTOMATIC"
      security_policy                 = module.backend_policy.policy.name
      edge_security_policy            = google_compute_security_policy.edge_policy.id
      session_affinity                = null
      affinity_cookie_ttl_sec         = null
      custom_request_headers          = null
      custom_response_headers         = null

      health_check = local.health_check
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
          group                        = module.mig["mig01"].instance_group
          balancing_mode               = "UTILIZATION"
          capacity_scaler              = null
          description                  = null
          max_connections              = null
          max_connections_per_instance = null
          max_connections_per_endpoint = null
          max_rate                     = null
          max_rate_per_instance        = null
          max_rate_per_endpoint        = null
          max_utilization              = 0.9
        },
      ]
      iap_config = {
        enable               = false
        oauth2_client_id     = null
        oauth2_client_secret = null
      }
    }

    web-app02 = {

      description                     = "Web App Backend 02"
      protocol                        = "HTTP"
      port                            = 80
      port_name                       = "http"
      timeout_sec                     = 600
      enable_cdn                      = true
      connection_draining_timeout_sec = null
      compression_mode                = "AUTOMATIC"
      security_policy                 = module.backend_policy.policy.name
      edge_security_policy            = google_compute_security_policy.edge_policy.id
      session_affinity                = null
      affinity_cookie_ttl_sec         = null
      custom_request_headers          = null
      custom_response_headers         = null

      health_check = local.health_check

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
          group                        = module.mig["mig02"].instance_group
          balancing_mode               = "UTILIZATION"
          capacity_scaler              = null
          description                  = null
          max_connections              = null
          max_connections_per_instance = null
          max_connections_per_endpoint = null
          max_rate                     = null
          max_rate_per_instance        = null
          max_rate_per_endpoint        = null
          max_utilization              = 0.9
        },
      ]
      iap_config = {
        enable               = false
        oauth2_client_id     = null
        oauth2_client_secret = null
      }
    }
  }
}

resource "google_compute_url_map" "traffic_mgmt" {
  count = var.url_map ? 1 : 0

  project = var.project_id

  name            = "lb-web-app"
  description     = "UrlMap used to route requests to a backend service based on rules."
  default_service = module.lb-http.backend_services["default"].self_link

  host_rule {
    hosts        = ["*"]
    path_matcher = "allpaths"
  }

  path_matcher {
    name            = "allpaths"
    default_service = module.lb-http.backend_services["default"].self_link

    path_rule {
      paths = ["/"]
      route_action {
        weighted_backend_services {
          backend_service = module.lb-http.backend_services["web-app01"].self_link
          weight          = 400
        }
        weighted_backend_services {
          backend_service = module.lb-http.backend_services["web-app02"].self_link
          weight          = 600
        }
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

  lifecycle {
    ignore_changes = [
      dashboard_json
    ]
  }

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
