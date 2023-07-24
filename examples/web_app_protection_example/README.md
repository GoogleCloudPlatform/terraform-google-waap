## First Commit: In this folder we will have examples related to the Managed Instance Group

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| backend\_port | value | `number` | `80` | no |
| base\_instance\_name\_r1 | The base instance name to use for instances in this group. | `string` | `"mig-backend-r1-vm"` | no |
| base\_instance\_name\_r2 | The base instance name to use for instances in this group. | `string` | `"mig-backend-r2-vm"` | no |
| disk\_size\_gb\_r1 | The size of the image in gigabytes. If not specified, it will inherit the size of its base image. | `string` | `"100"` | no |
| disk\_size\_gb\_r2 | The size of the image in gigabytes. If not specified, it will inherit the size of its base image. | `string` | `"100"` | no |
| enable\_cdn | value | `bool` | `true` | no |
| machine\_type\_r1 | Machine type to create, e.g. n1-standard-1 | `string` | `"e2-small"` | no |
| machine\_type\_r2 | Machine type to create, e.g. n1-standard-1 | `string` | `"e2-small"` | no |
| mig\_name\_r1 | Name of the managed instance group. | `string` | `"mig-backend-r1"` | no |
| mig\_name\_r2 | Name of the managed instance group. | `string` | `"mig-backend-r2"` | no |
| name\_prefix\_r1 | Name prefix for the instance template | `string` | `"vm-template-"` | no |
| name\_prefix\_r2 | Name prefix for the instance template | `string` | `"vm-template-"` | no |
| network\_name\_r1 | VPC network name | `string` | `"webapp-r1"` | no |
| network\_name\_r2 | VPC network name | `string` | `"webapp-r2"` | no |
| project\_id | Google Project ID | `string` | `"ci-waap-a106"` | no |
| region\_r1 | Region in which to create resources | `string` | `"us-central1"` | no |
| region\_r2 | Region in which to create resources | `string` | `"us-east1"` | no |
| service\_account\_id\_r1 | The account ID used to generate the virtual machine service account. | `string` | `"sa-backend-vm-r1"` | no |
| service\_account\_id\_r2 | The account ID used to generate the virtual machine service account. | `string` | `"sa-backend-vm-r2"` | no |
| service\_account\_roles\_r1 | Permissions to be added to the created service account. | `list(string)` | <pre>[<br>  "roles/monitoring.metricWriter",<br>  "roles/logging.logWriter"<br>]</pre> | no |
| service\_account\_roles\_r2 | Permissions to be added to the created service account. | `list(any)` | <pre>[<br>  "roles/monitoring.metricWriter",<br>  "roles/logging.logWriter"<br>]</pre> | no |
| service\_account\_scopes\_r1 | List of scopes for the instance template service account | `list(any)` | <pre>[<br>  "logging-write",<br>  "monitoring-write",<br>  "cloud-platform"<br>]</pre> | no |
| service\_account\_scopes\_r2 | List of scopes for the instance template service account | `list(any)` | <pre>[<br>  "logging-write",<br>  "monitoring-write",<br>  "cloud-platform"<br>]</pre> | no |
| source\_image\_r1 | Image used for compute VMs. | `string` | `"debian-cloud/debian-11"` | no |
| source\_image\_r2 | Image used for compute VMs. | `string` | `"debian-cloud/debian-11"` | no |
| subnet\_ip\_r1 | This is th IP of your subnet | `string` | `"10.0.16.0/24"` | no |
| subnet\_ip\_r2 | This is th IP of your subnet | `string` | `"10.0.32.0/24"` | no |
| subnet\_name\_r1 | Subnet name | `string` | `"webapp-r1"` | no |
| subnet\_name\_r2 | Subnet name | `string` | `"webapp-r2"` | no |
| subnet\_region\_r1 | Subnet Region | `string` | `"us-central1"` | no |
| subnet\_region\_r2 | Subnet Region | `string` | `"us-east1"` | no |
| tags\_r1 | Network tags, provided as a list | `list(string)` | <pre>[<br>  "backend-r1"<br>]</pre> | no |
| tags\_r2 | Network tags, provided as a list | `list(string)` | <pre>[<br>  "backend-r2"<br>]</pre> | no |
| target\_size\_r1 | The target number of running instances for this managed instance group. This value should always be explicitly set unless this resource is attached to an autoscaler, in which case it should never be set. | `number` | `1` | no |
| target\_size\_r2 | The target number of running instances for this managed instance group. This value should always be explicitly set unless this resource is attached to an autoscaler, in which case it should never be set. | `number` | `1` | no |
| zone\_r1 | value | `string` | `"us-central1-b"` | no |
| zone\_r2 | value | `string` | `"us-east1-b"` | no |

## Outputs

No outputs.

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
