## First Commit: In this folder we will have code related to the base for environments using Maged Instance Groups

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| network\_name | VPC network name | `string` | `""` | no |
| project\_id | Google Project ID | `string` | `""` | no |
| region | Region in which to create resources | `string` | `""` | no |
| subnet\_ip | This is th IP of your subnet | `string` | `""` | no |
| subnet\_name | Subnet name | `string` | `""` | no |
| subnet\_region | Subnet Region | `string` | `""` | no |

## Outputs

| Name | Description |
|------|-------------|
| network\_name | The name of the VPC being created |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
