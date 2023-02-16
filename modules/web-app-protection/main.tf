// HTTP Load Balancer
module "lb-http" {
  source  = "GoogleCloudPlatform/lb-http/google"
  version = "~> 6.3.0"

  project     = var.project_id
  name        = "juiceshop"
  target_tags = ["juiceshop"]

  firewall_networks    = [module.vpc.network_name]
  address              = module.nip_juiceshop_hostname.ip_address
  create_address       = false
  ssl                  = true
  use_ssl_certificates = true
  ssl_certificates     = ["https://www.googleapis.com/compute/v1/${module.nip_juiceshop_hostname.ssl_certificate}"]
  https_redirect       = true

  backends = {
    default = {
      description             = null
      protocol                = "HTTP"
      port                    = 80
      port_name               = "http"
      timeout_sec             = 10

      // Cloud CDN
      enable_cdn = var.enable_cdn

      custom_request_headers  = null
      custom_response_headers = null
      security_policy         = module.cloud_armor.policy.name

      connection_draining_timeout_sec = null
      session_affinity                = null
      affinity_cookie_ttl_sec         = null

      health_check = var.health_check

      log_config = {
        enable      = true
        sample_rate = 1.0
      }

      groups = [
        {
          group                        = module.mig.instance_group
          max_utilization              = null
          balancing_mode               = null
          capacity_scaler              = null
          description                  = null
          max_connections              = null
          max_connections_per_instance = null
          max_connections_per_endpoint = null
          max_rate                     = null
          max_rate_per_instance        = null
          max_rate_per_endpoint        = null
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

// Cloud Armor
module "cloud_armor" {
  source = "GoogleCloudPlatform/cloud-armor/google"

  project_id                           = var.project_id
  name                                 = var.cloud_armor_policy_name
  description                          = var.cloud_armor_policy_description
  default_rule_action                  = var.default_rule_action
  type                                 = "CLOUD_ARMOR"
  layer_7_ddos_defense_enable          = var.layer_7_ddos_defense_enable
  layer_7_ddos_defense_rule_visibility = var.layer_7_ddos_defense_rule_visibility

  pre_configured_rules         = var.pre_configured_rules
  security_rules               = var.security_rules
  custom_rules                 = var.custom_rules
  threat_intelligence_rules    = var.threat_intelligence_rules
}