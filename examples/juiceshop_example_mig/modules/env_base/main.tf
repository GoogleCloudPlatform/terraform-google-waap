/*****************
*** Create VPC ***
******************/
module "mig_vpc" {
    source  = "terraform-google-modules/network/google"
    version = "~> 6.0"

    project_id   = var.project_id
    network_name = var.network_name
    routing_mode = "GLOBAL"

    subnets = [
        {
            subnet_name           = var.subnet_name
            subnet_ip             = var.subnet_ip
            subnet_region         = var.default_region
        }
    ]
}

/***********************
*** Create Cloud NAT ***
************************/

module "cloud-nat" {
    source            = "terraform-google-modules/cloud-nat/google"
    version           = "~> 1.2"
    create_router     = true
    project_id        = var.project_id
    region            = var.default_region #!TODO
    network           = module.mig_vpc.network_name #!TODO
    router            = format("router-%s", var.network_name)
    name              = format("nat-%s", var.network_name)
}

/**********************************************************************************
**** Firewall rule to allow incoming ssh connections from Google IAP servers. ****
**********************************************************************************/
resource "google_compute_firewall" "inbound-ip-ssh" {
    name        = "allow-ssh-iap"
    project     = var.project_id
    network     = module.mig_vpc.network_name #!TODO

    direction = "INGRESS"
    allow {
        protocol = "tcp"
        ports    = ["22","8080"] # SSH port and Jenkins port  
    }
    source_ranges = [
        "35.235.240.0/20"
    ]
    source_tags = ["allow-ssh-iap"]

}