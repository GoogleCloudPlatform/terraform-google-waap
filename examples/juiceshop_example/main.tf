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


module "vpc" {
  source  = "terraform-google-modules/network/google"
  version = "~> 4.0"

  project_id   = var.project_id
  network_name = "waap-vpc"
  routing_mode = "GLOBAL"

  subnets = [
    {
      subnet_name   = "apigee-neg-subnet"
      subnet_ip     = "10.0.4.0/22"
      subnet_region = var.region
    },
    {
      subnet_name   = "juiceshop-subnet"
      subnet_ip     = "10.0.8.0/22"
      subnet_region = var.region
    }
  ]
}

module "cloud_router" {
  source  = "terraform-google-modules/cloud-router/google"
  version = "~> 4.0"
  project = var.project_id
  name    = "juiceshop-router"
  network = module.vpc.network_name
  region  = var.region

  nats = [{
    name = "juiceshop-nat"
  }]
}

module "apigee" {
  source = "../../modules/apigee"

  project_id          = var.project_id
  billing_type        = "EVALUATION"
  ax_region           = var.region
  apigee_environments = ["demo"]
  apigee_envgroups = {
    demo = {
      environments = ["demo"]
      hostnames    = [module.nip_apigee_hostname.hostname]
    }
  }
  apigee_instances = {
    instance-1 = {
      region       = var.region
      ip_range     = "10.0.0.0/22"
      environments = ["demo"]
    }
  }
  network_id = module.vpc.network_id
  subnet_id  = module.vpc.subnets_ids[0]

  ssl_certificate = module.nip_apigee_hostname.ssl_certificate
  external_ip     = module.nip_apigee_hostname.ip_address
}

module "nip_apigee_hostname" {
  source = "github.com/apigee/terraform-modules//modules/nip-development-hostname?ref=v0.12.0"

  project_id         = var.project_id
  address_name       = "apigee-external"
  subdomain_prefixes = ["demo"]
}

# ----------------------------------------------------------------------------------------------------------------------
# Configure 3P Apigee
# ----------------------------------------------------------------------------------------------------------------------
data "google_client_config" "current" {}

provider "apigee" {
  access_token = data.google_client_config.current.access_token
  organization = module.apigee.apigee_org_id
  server       = "apigee.googleapis.com"
}

resource "apigee_proxy" "juiceshop_proxy" {
  name        = "waap-demo-proxy-bundle"
  bundle      = "${path.module}/waap-demo-proxy-bundle.zip"
  bundle_hash = filebase64sha256("${path.module}/waap-demo-proxy-bundle.zip")

  depends_on = [
    module.apigee
  ]
}

resource "apigee_proxy_deployment" "juiceshop_proxy_deployment" {
  proxy_name       = apigee_proxy.juiceshop_proxy.name
  environment_name = "demo"
  revision         = apigee_proxy.juiceshop_proxy.revision

  depends_on = [
    apigee_target_server.target_server
  ]
}

resource "apigee_target_server" "target_server" {
  environment_name = "demo"
  name             = "waap-demo-ts"
  host             = module.nip_juiceshop_hostname.hostname
  port             = 443
  ssl_enabled      = true

  depends_on = [
    module.apigee
  ]
}

resource "apigee_product" "juiceshop_product" {
  name               = "waap-product"
  display_name       = "waap-product"
  auto_approval_type = true
  environments = [
    "demo"
  ]
  #   scopes = [
  #     "openid",
  #     "profile"
  #   ]
  attributes = {
    access = "public"
  }
  operation {
    api_source = apigee_proxy.juiceshop_proxy.name
    path       = "/"
    methods    = ["GET"]
  }
}

resource "apigee_developer" "example" {
  email      = "developer@waap.com"
  first_name = "WAAP"
  last_name  = "Developer"
  user_name  = "waap"

  depends_on = [
    module.apigee
  ]
}

resource "apigee_developer_app" "example" {
  developer_email = apigee_developer.example.email
  name            = "JuiceShop"
}

resource "apigee_developer_app_credential" "example" {
  developer_email    = apigee_developer.example.email
  developer_app_name = apigee_developer_app.example.name
  consumer_key       = "12345"
  consumer_secret    = "secret"
  api_products = [
    apigee_product.juiceshop_product.name
  ]
}

# ----------------------------------------------------------------------------------------------------------------------
# JuiceShop App
# ----------------------------------------------------------------------------------------------------------------------
resource "google_recaptcha_enterprise_key" "primary" {
  display_name = "juiceshop-session-token-key"

  project = var.project_id

  web_settings {
    integration_type  = "SCORE"
    allow_all_domains = true
  }
}

resource "google_artifact_registry_repository" "waap_repo" {
  format        = "DOCKER"
  location      = var.region
  project       = var.project_id
  repository_id = "waap-repo"
}


# Clone Git Repo
resource "null_resource" "git_clone_source" {
  provisioner "local-exec" {
    command = "git clone https://github.com/ssvaidyanathan/juice-shop.git ${path.module}/juice-shop"
  }
}

resource "time_sleep" "wait_for_git_seconds" {
  depends_on = [
    null_resource.git_clone_source
  ]

  create_duration = "60s"
}

# Build Docker Image
module "build_juiceshop_image" {
  source  = "terraform-google-modules/gcloud/google"
  version = "~> 2.0"

  platform = "linux"

  create_cmd_entrypoint = "gcloud"
  create_cmd_body       = "builds submit ${path.module}/juice-shop/ --config=${path.module}/juice-shop/cloudbuild.yaml --project=${var.project_id} --substitutions=_API_ENDPOINT=https://${module.nip_apigee_hostname.hostname},_BASEPATH=/owasp,_APIKEY=${apigee_developer_app_credential.example.consumer_key},_RECAPTCHA_KEY=${google_recaptcha_enterprise_key.primary.name},_IMAGETAG=${var.region}-docker.pkg.dev/${var.project_id}/${google_artifact_registry_repository.waap_repo.repository_id}/juiceshop-image"

  module_depends_on = [
    time_sleep.wait_for_git_seconds
  ]
}

# ----------------------------------------------------------------------------------------------------------------------
# JuiceShop Infra
# ----------------------------------------------------------------------------------------------------------------------
locals {
  health_check = {
    type                = "http"
    check_interval_sec  = 10
    healthy_threshold   = 2
    timeout_sec         = 5
    unhealthy_threshold = 3
    port                = 3000
    request_path        = "/rest/admin/application-version"
    host                = null
    initial_delay_sec   = 30
    proxy_header        = "NONE"
    request             = null
    response            = null
    logging             = true
  }
}

data "google_compute_default_service_account" "default" {
  project = var.project_id
}

module "gce_container" {
  source  = "terraform-google-modules/container-vm/google"
  version = "~> 3.0"

  container = {
    name  = "juiceshop-demo-mig-template"
    image = "${var.region}-docker.pkg.dev/${var.project_id}/${google_artifact_registry_repository.waap_repo.repository_id}/juiceshop-image"
    securityContext = {
      privileged : false
    }
    stdin : false
    tty : true

    # Declare volumes to be mounted.
    # This is similar to how docker volumes are declared.
    volumeMounts = []
  }

  # Declare the Volumes which will be used for mounting.
  volumes = []

  restart_policy = "Always"

  depends_on = [
    module.build_juiceshop_image
  ]
}

module "instance_template" {
  source  = "terraform-google-modules/vm/google//modules/instance_template"
  version = "~> 7.9.0"

  name_prefix = "juiceshop-instance-template"
  project_id  = var.project_id
  service_account = {
    email  = data.google_compute_default_service_account.default.email
    scopes = ["cloud-platform"]
  }
  machine_type = "n2-standard-2"
  labels = {
    container-vm = module.gce_container.vm_container_label
  }
  metadata = {
    google-logging-enabled    = "true",
    google-monitoring-enabled = "true"
    gce-container-declaration = module.gce_container.metadata_value
  }
  tags = ["http-server", "https-server", "juiceshop"]

  /* network */
  network            = module.vpc.network_id
  subnetwork         = module.vpc.subnets_ids[1]
  subnetwork_project = var.project_id

  access_config = [{
    network_tier = "PREMIUM"
    nat_ip       = null
  }]
  automatic_restart   = true
  on_host_maintenance = "MIGRATE"

  /* image */
  source_image = module.gce_container.source_image
  #   source_image_project = var.project_id

  /* disks */
  disk_size_gb = 10
  disk_type    = "pd-balanced"
  auto_delete  = true
}

module "mig" {
  source  = "terraform-google-modules/vm/google//modules/mig"
  version = "~> 7.9.0"

  project_id        = var.project_id
  hostname          = "juiceshop-demo"
  region            = var.region
  instance_template = module.instance_template.self_link
  #   target_size               = var.target_size
  #   target_pools              = var.target_pools
  #   distribution_policy_zones = var.distribution_policy_zones
  named_ports = [{
    name = "http-juiceshop"
    port = 3000
  }]

  update_policy = [{
    minimal_action               = "REPLACE"
    type                         = "PROACTIVE"
    instance_redistribution_type = null
    max_surge_fixed              = 0
    max_surge_percent            = null
    max_unavailable_fixed        = 4
    max_unavailable_percent      = null
    min_ready_sec                = null
    replacement_method           = null
  }]

  /* health check */
  health_check = local.health_check

  /* autoscaler */
  autoscaling_enabled = true
  max_replicas        = 2
  min_replicas        = 1
  cooldown_period     = 60
  autoscaling_cpu = [
    {
      target            = 0.6
      predictive_method = null
    },
  ]
}


module "nip_juiceshop_hostname" {
  source = "github.com/apigee/terraform-modules//modules/nip-development-hostname?ref=v0.12.0"

  project_id   = var.project_id
  address_name = "juiceshop-lb-ip"
}

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
      port_name               = "http-juiceshop"
      timeout_sec             = 10
      enable_cdn              = false
      custom_request_headers  = null
      custom_response_headers = null
      security_policy         = google_compute_security_policy.waap_policies.name

      connection_draining_timeout_sec = null
      session_affinity                = null
      affinity_cookie_ttl_sec         = null

      health_check = local.health_check

      log_config = {
        enable      = true
        sample_rate = 1.0
      }

      groups = [
        {
          # Each node pool instance group should be added to the backend.
          group                        = module.mig.instance_group
          max_utilization              = 0.8
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



# ----------------------------------------------------------------------------------------------------------------------
# Firewalls
# ----------------------------------------------------------------------------------------------------------------------
module "firewall_rules" {
  source  = "terraform-google-modules/network/google//modules/firewall-rules"
  version = "~> 6.0.0"

  project_id   = var.project_id
  network_name = module.vpc.network_name

  rules = [
    {
      name                    = "allow-all-egress-juiceshop-https"
      description             = null
      direction               = "EGRESS"
      priority                = 1000
      ranges                  = ["0.0.0.0/0"]
      source_tags             = null
      source_service_accounts = null
      target_tags             = ["juiceshop"]
      target_service_accounts = null
      allow = [
        {
          protocol = "tcp"
          ports    = ["443"]
        }
      ]
      deny = []
      log_config = {
        metadata = "INCLUDE_ALL_METADATA"
      }
    },
    {
      name                    = "allow-juiceshop-demo-lb-health-check"
      description             = null
      direction               = "INGRESS"
      priority                = 1000
      ranges                  = ["130.211.0.0/22", "35.191.0.0/16"]
      source_tags             = null
      source_service_accounts = null
      target_tags             = ["juiceshop"]
      target_service_accounts = null
      allow = [
        {
          protocol = "tcp"
          ports    = ["80", "443", "3000"]
        }
      ]
      deny = []
      log_config = {
        metadata = "INCLUDE_ALL_METADATA"
      }
    },
    {
      name                    = "default-allow-http"
      description             = null
      direction               = "INGRESS"
      priority                = 1000
      ranges                  = ["0.0.0.0/0"]
      source_tags             = null
      source_service_accounts = null
      target_tags             = ["http-server"]
      target_service_accounts = null
      allow = [
        {
          protocol = "tcp"
          ports    = ["80"]
        }
      ]
      deny = []
      log_config = {
        metadata = "INCLUDE_ALL_METADATA"
      }
    },
    {
      name                    = "default-allow-https"
      description             = null
      direction               = "INGRESS"
      priority                = 1000
      ranges                  = ["0.0.0.0/0"]
      source_tags             = null
      source_service_accounts = null
      target_tags             = ["https-server"]
      target_service_accounts = null
      allow = [
        {
          protocol = "tcp"
          ports    = ["443"]
        }
      ]
      deny = []
      log_config = {
        metadata = "INCLUDE_ALL_METADATA"
      }
    },
    {
      name                    = "default-allow-http-3000"
      description             = null
      direction               = "INGRESS"
      priority                = 1000
      ranges                  = ["0.0.0.0/0"]
      source_tags             = null
      source_service_accounts = null
      target_tags             = null
      target_service_accounts = null
      allow = [
        {
          protocol = "tcp"
          ports    = ["3000"]
        }
      ]
      deny = []
      log_config = {
        metadata = "INCLUDE_ALL_METADATA"
      }
    },
    {
      name                    = "default-allow-custom"
      description             = "Allows connection from any source to any instance on the network using custom protocols."
      direction               = "INGRESS"
      priority                = 65534
      ranges                  = ["10.0.32.0/20"]
      source_tags             = null
      source_service_accounts = null
      target_tags             = null
      target_service_accounts = null
      allow = [
        {
          protocol = "all"
          ports    = []
        }
      ]
      deny = []
      log_config = {
        metadata = "INCLUDE_ALL_METADATA"
      }
    },
    {
      name                    = "all-rdp-ssh-iap"
      description             = "Allows RDP/SSH connections from IAP."
      direction               = "INGRESS"
      priority                = 65534
      ranges                  = ["35.235.240.0/20"]
      source_tags             = null
      source_service_accounts = null
      target_tags             = null
      target_service_accounts = null
      allow = [
        {
          ports    = ["3389", "22"]
          protocol = "tcp"
        }
      ]
      deny = []
      log_config = {
        metadata = "INCLUDE_ALL_METADATA"
      }
    },
  ]
}

# ----------------------------------------------------------------------------------------------------------------------
# Configure Cloud Armour
# ----------------------------------------------------------------------------------------------------------------------
resource "google_compute_security_policy" "waap_policies" {
  name    = "waap-demo-juice-shop"
  project = var.project_id

  rule {
    action      = "allow"
    description = "Default rule, higher priority overrides it"

    match {
      config {
        src_ip_ranges = ["*"]
      }
      versioned_expr = "SRC_IPS_V1"
    }
    priority = 2147483647
  }

  rule {
    action      = "deny(403)"
    description = "Deny all requests below 0.9 recaptcha score"

    match {
      expr {
        expression = "recaptchaTokenScore() <= 0.9"
      }
    }
    priority = 8998
  }

  rule {
    action      = "deny(403)"
    description = "Block US IP & header: Hacker"

    match {
      expr {
        expression = "origin.region_code == 'US' && request.headers['user-agent'].contains('Hacker')"
      }
    }
    priority = 7000
  }

  rule {
    action      = "deny(403)"
    description = "Regular Expression Rule"

    match {
      expr {
        expression = "request.headers['user-agent'].contains('Hacker')"
      }
    }
    priority = 7001
  }

  rule {
    action      = "deny(403)"
    description = "block sql injection"

    match {
      expr {
        expression = "evaluatePreconfiguredExpr('sqli-stable', ['owasp-crs-v030001-id942251-sqli', 'owasp-crs-v030001-id942420-sqli', 'owasp-crs-v030001-id942431-sqli', 'owasp-crs-v030001-id942460-sqli', 'owasp-crs-v030001-id942421-sqli', 'owasp-crs-v030001-id942432-sqli'])"
      }
    }
    priority = 9000
  }

  rule {
    action      = "deny(403)"
    description = "block xss"

    match {
      expr {
        expression = "evaluatePreconfiguredExpr('xss-stable', ['owasp-crs-v030001-id941110-xss', 'owasp-crs-v030001-id941120-xss', 'owasp-crs-v030001-id941130-xss', 'owasp-crs-v030001-id941140-xss', 'owasp-crs-v030001-id941160-xss', 'owasp-crs-v030001-id941170-xss', 'owasp-crs-v030001-id941180-xss', 'owasp-crs-v030001-id941190-xss', 'owasp-crs-v030001-id941200-xss', 'owasp-crs-v030001-id941210-xss', 'owasp-crs-v030001-id941220-xss', 'owasp-crs-v030001-id941230-xss', 'owasp-crs-v030001-id941240-xss', 'owasp-crs-v030001-id941250-xss', 'owasp-crs-v030001-id941260-xss', 'owasp-crs-v030001-id941270-xss', 'owasp-crs-v030001-id941280-xss', 'owasp-crs-v030001-id941290-xss', 'owasp-crs-v030001-id941300-xss', 'owasp-crs-v030001-id941310-xss', 'owasp-crs-v030001-id941350-xss', 'owasp-crs-v030001-id941150-xss', 'owasp-crs-v030001-id941320-xss', 'owasp-crs-v030001-id941330-xss', 'owasp-crs-v030001-id941340-xss'])"
      }
    }
    priority = 3000
  }

  rule {
    action      = "deny(403)"
    description = "block local file inclusion"

    match {
      expr {
        expression = "evaluatePreconfiguredExpr('lfi-stable')"
      }
    }
    priority = 9005
  }

  rule {
    action      = "deny(403)"
    description = "block local file inclusion"

    match {
      expr {
        expression = "evaluatePreconfiguredExpr('rce-stable')"
      }
    }
    priority = 9010
  }

  rule {
    action      = "deny(403)"
    description = "block local file inclusion"

    match {
      expr {
        expression = "evaluatePreconfiguredExpr('scannerdetection-stable')"
      }
    }
    priority = 9015
  }

  rule {
    action      = "deny(403)"
    description = "block local file inclusion"

    match {
      expr {
        expression = "evaluatePreconfiguredExpr('protocolattack-stable')"
      }
    }
    priority = 9020
  }

  rule {
    action      = "deny(403)"
    description = "block local file inclusion"

    match {
      expr {
        expression = "evaluatePreconfiguredExpr('sessionfixation-stable')"
      }
    }
    priority = 9025
  }

}
