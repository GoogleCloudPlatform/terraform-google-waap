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

  source_image         = "family/${var.source_image_r2}"
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