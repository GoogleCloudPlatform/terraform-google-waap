# MIG Network submodule

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| network\_name | VPC network name | `string` | `""` | no |
| project\_id | Google Project ID | `string` | `""` | no |
| region | Region in which to create resources | `string` | `""` | no |
| subnets | List of subnet configurations | <pre>list(object({<br>    subnet_name   = string<br>    subnet_ip     = string<br>    subnet_region = string<br>  }))</pre> | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| network\_name | The name of the VPC being created |
| subnets | List of created subnets |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
