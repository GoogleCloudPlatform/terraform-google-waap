/***********************
*** Shared Variables ***
************************/
project_id   = "ci-waap-caba"


/*************************
*** Region 1 Variables ***
**************************/
region_r1                   = "us-central1"
zone_r1                     = "us-central1-b"
network_name_r1             = "webapp-r1"  # prefix vpc
subnet_name_r1              = "webapp-r1"  # prefix subnet
subnet_ip_r1                = "10.0.16.0/24"
subnet_region_r1            = "us-central1"

name_prefix_r1              = "vm-template-"
machine_type_r1             = "e2-small"
tags_r1                     = [ "backend-r1" ]

source_image_r1             = "ubuntu-2204-lts"
disk_size_gb_r1             = "100"

service_account_id_r1       = "sa-backend-vm-r1"
service_account_roles_r1    = [ "roles/monitoring.metricWriter", "roles/logging.logWriter" ]
service_account_scopes_r1   = [ "logging-write", "monitoring-write", "cloud-platform" ]

mig_name_r1                 = "mig-backend-r1"
base_instance_name_r1       = "mig-backend-r1-vm"
target_size_r1              = 1

/*************************
*** Region 2 Variables ***
**************************/

region_r2                   = "us-east1"
zone_r2                     = "us-east1-b"
network_name_r2             = "webapp-r2"  # prefix vpc
subnet_name_r2              = "webapp-r2"  # prefix subnet
subnet_ip_r2                = "10.0.32.0/24"
subnet_region_r2            = "us-east1"

name_prefix_r2              = "vm-template-"
machine_type_r2             = "e2-small"
tags_r2                     = [ "backend-r2" ]

source_image_r2             = "ubuntu-2204-lts"
disk_size_gb_r2             = "100"

service_account_id_r2       = "sa-backend-vm-r2"
service_account_roles_r2    = [ "roles/monitoring.metricWriter", "roles/logging.logWriter" ]
service_account_scopes_r2   = [ "logging-write", "monitoring-write", "cloud-platform" ]

mig_name_r2                 = "mig-backend-r2"
base_instance_name_r2       = "mig-backend-r2-vm"
target_size_r2              = 1