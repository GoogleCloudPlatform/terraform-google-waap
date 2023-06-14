## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| project\_id | Google Project ID | string | n/a | Yes |
| region | Region for cloud resources. | string | us-central1 | Yes |
| network\_name | VPC network name | string | n/a | Yes |
| subnet\_name | Subnet name | string | n/a | Yes |
| subnet\_ip | This is the IP range of your subnet | string | n/a | Yes |
| subnet\_region | Subnet Region | string | n/a | Yes |

## Outputs

| Name | Description |
|------|-------------|
| network\_name | The name of the VPC being created |
