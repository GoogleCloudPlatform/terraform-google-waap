locals {
  environment = "dev"
}

data "template_file" "startup_script" {
  template  = <<EOT
    #!/bin/bash
    set -x
    curl -sSO https://dl.google.com/cloudagents/add-google-cloud-ops-agent-repo.sh
    sudo bash add-google-cloud-ops-agent-repo.sh --also-install
    
    # Install docker and run the juice shop application.
    sudo apt-get -y install ca-certificates curl gnupg lsb-release
    sudo mkdir -m 0755 -p /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg  
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian \
    $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    apt-get update
    sudo apt-get -y install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
    docker pull bkimminich/juice-shop
    docker run -d -p 80:3000 bkimminich/juice-shop
    EOT
}

module "network_mig_r1" {
    source = "../../../../modules/mig_network"

    project_id    = var.project_id
    region        = var.region_r1
    network_name  = var.network_name_r1
    subnet_name   = var.subnet_name_r1
    subnet_ip     = var.subnet_ip_r1
    subnet_region = var.subnet_region_r1
}

module "network_mig_r2" {
    source = "../../../../modules/mig_network"

    project_id    = var.project_id
    region        = var.region_r2
    network_name  = var.network_name_r2
    subnet_name   = var.subnet_name_r2
    subnet_ip     = var.subnet_ip_r2
    subnet_region = var.subnet_region_r2
}

module "mig_r1" {
  source = "../../../../modules/mig"

  # VM Template
  project_id          = var.project_id
  region              = var.region_r1
  name_prefix         = var.name_prefix_r1
  machine_type        = var.machine_type_r1
  tags                = var.tags_r1

  source_image        = var.source_image_r1
  disk_size_gb        = var.disk_size_gb_r1

  service_account     = var.service_account_id_r1
  roles               = var.service_account_roles_r1
  scopes              = var.service_account_scopes_r1

  startup_script      = "${data.template_file.startup_script.rendered}"

  network             = var.network_name_r1
  subnetwork          = var.subnet_name_r1
  
  # Managed Instance Group
  mig_name            = var.mig_name_r1
  base_instance_name  = var.base_instance_name_r1
  zone                = var.zone_r1

  target_size         = var.target_size_r1
}

module "mig_r2" {
  source = "../../../../modules/mig"

  # VM Template
  project_id           = var.project_id
  region               = var.region_r2
  name_prefix          = var.name_prefix_r2
  machine_type         = var.machine_type_r2
  tags                 = var.tags_r2

  source_image         = var.source_image_r2
  disk_size_gb         = var.disk_size_gb_r2

  service_account      = var.service_account_id_r2
  roles                = var.service_account_roles_r2
  scopes               = var.service_account_scopes_r2

  startup_script       = "${data.template_file.startup_script.rendered}"

  network              = var.network_name_r2
  subnetwork           = var.subnet_name_r2
  
  

  # Managed Instance Group
  mig_name             = var.mig_name_r2
  base_instance_name   = var.base_instance_name_r2
  zone                 = var.zone_r2

  target_size          = var.target_size_r2
   
}

resource "random_id" "suffix" {
  byte_length = 4
}

module "security_policy" {
  source = "../../../../modules/cloud-armor"
  
  project_id  = var.project_id 
  name        = "ca-policy-${random_id.suffix.hex}"
  description = "Cloud Armor Security Policy"
  type        = "CLOUD_ARMOR"

  edge_rules = {
    "geo_us" = {
      action          = "allow"
      priority        = "1000"
      expression      = "US"
      description     = "US Geolocalization Rule"
    }

    "src_hc_ip" = {
      action          = "allow"
      priority        = "1001"
      versioned_expr  = "SRC_IPS_V1"
      src_ip_ranges   = ["35.191.0.0/16"]
      description     = "Rule to allow healthcheck IP range"
    }
  }
}

module "lb-http" {
  source  = "GoogleCloudPlatform/lb-http/google"
  version = "7.0.0"

  name    = "lb-web-app"
  project = var.project_id
  target_tags = ["backend-r1", "backend-r2"]
  
  firewall_networks = [module.network_mig_r1.network_name, module.network_mig_r2.network_name]
  firewall_projects = [var.project_id, var.project_id]
  
  backends = {
    default = {

      description                     = null
      protocol                        = "HTTP"
      port                            = var.backend_port
      port_name                       = "http"
      timeout_sec                     = 10
      enable_cdn                      = var.enable_cdn
      connection_draining_timeout_sec = null
      compression_mode                = "AUTOMATIC"
      security_policy                 = module.security_policy.policy
      session_affinity                = null
      affinity_cookie_ttl_sec         = null
      custom_request_headers          = null
      custom_response_headers         = null

      health_check = {
        check_interval_sec  = null
        timeout_sec         = null
        healthy_threshold   = null
        unhealthy_threshold = null
        request_path        = "/"
        port                = var.backend_port
        host                = null
        logging             = null
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
          balancing_mode               = null
          capacity_scaler              = null
          description                  = null
          max_connections              = null
          max_connections_per_instance = null
          max_connections_per_endpoint = null
          max_rate                     = null
          max_rate_per_instance        = null
          max_rate_per_endpoint        = null
          max_utilization              = null
        },
        {
          group                        = module.mig_r2.instance_group
          balancing_mode               = null
          capacity_scaler              = null
          description                  = null
          max_connections              = null
          max_connections_per_instance = null
          max_connections_per_endpoint = null
          max_rate                     = null
          max_rate_per_instance        = null
          max_rate_per_endpoint        = null
          max_utilization              = null
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