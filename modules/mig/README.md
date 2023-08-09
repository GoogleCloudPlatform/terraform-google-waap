# MIG submodule

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| backend\_port | The backend port number. | `number` | `80` | no |
| disk\_auto\_delete | Whether or not the disk should be auto-deleted. | `bool` | `true` | no |
| disk\_size\_gb | The size of the image in gigabytes. If not specified, it will inherit the size of its base image. | `string` | `"100"` | no |
| disk\_type | The GCE disk type. Can be either pd-ssd, local-ssd, pd-balanced or pd-standard. | `string` | `"pd-standard"` | no |
| machine\_type | Machine type to create, e.g. n1-standard-1 | `string` | `"n1-standard-1"` | no |
| max\_surge\_fixed | The maximum number of instances that can be created above the specified targetSize during the update process. | `number` | n/a | yes |
| max\_unavailable\_fixed | The maximum number of instances that can be unavailable during the update process. | `number` | n/a | yes |
| mig\_name | Name of the managed instance group. | `string` | `""` | no |
| name\_prefix | Name prefix for the instance template | `string` | `"vm-template-"` | no |
| network | Name of the network to deploy instances to. | `string` | `"default"` | no |
| port\_name | The name of the port. | `string` | `"http"` | no |
| project\_id | Google Project ID | `string` | `""` | no |
| region | Region for cloud resources. | `string` | `"us-central1"` | no |
| roles | Permissions to be added to the created service account. | `list(any)` | `[]` | no |
| scopes | List of scopes for the instance template service account | `list(any)` | `[]` | no |
| service\_account | The account ID used to generate the virtual machine service account. | `string` | `""` | no |
| source\_image | Source disk image. If neither source\_image nor source\_image\_family is specified, defaults to the latest public CentOS image. | `string` | `""` | no |
| source\_image\_project | Project where the source image comes from. The default project contains CentOS images. | `string` | `""` | no |
| startup\_script | VM startup script. | `string` | `""` | no |
| subnetwork | The subnetwork to deploy to | `string` | `"default"` | no |
| tags | Network tags, provided as a list | `list(string)` | `[]` | no |
| target\_size | The target number of running instances for this managed instance group. This value should always be explicitly set unless this resource is attached to an autoscaler, in which case it should never be set. | `number` | `1` | no |

## Outputs

| Name | Description |
|------|-------------|
| instance\_group | Managed instance group |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
