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

module "mig_network" {
    source = "../../../../modules/mig_network"

    project_id    = "cicd-prj-bbee"
    region        = var.region
    network_name  = var.network_name
    subnet_name   = var.subnet_name
    subnet_ip     = var.subnet_ip
    subnet_region = var.subnet_region
}

module "mig" {
  source = "../../../../modules/mig"

  project_id      = ""
  region          = var.region
  name_prefix     = ""
  machine_type    = ""
  tags            = ""

  source_image    = ""
  auto_delete     = ""
  disk_type       = ""
  disk_size_gb    = ""
  mode            = "" 

  email           = ""
  scopes          = ""

  startup_script  = "${data.template_file.startup_script.rendered}" 
}