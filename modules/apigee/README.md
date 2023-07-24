<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| analytics\_region | GCP region for storing Apigee analytics data (see https://cloud.google.com/apigee/docs/api-platform/get-started/install-cli). | `string` | n/a | yes |
| apigee\_endpoint\_attachments | Apigee endpoint attachments (for southbound networking: https://cloud.google.com/apigee/docs/api-platform/architecture/southbound-networking-patterns-endpoints#create-the-psc-attachments). | <pre>map(object({<br>    region             = string<br>    service_attachment = string<br>  }))</pre> | `{}` | no |
| apigee\_envgroups | Apigee groups (NAME => [HOSTNAMES]). | `map(list(string))` | `null` | no |
| apigee\_environments | Apigee Environments. | <pre>map(object({<br>    display_name    = optional(string)<br>    description     = optional(string, "Terraform-managed")<br>    deployment_type = optional(string)<br>    api_proxy_type  = optional(string)<br>    node_config = optional(object({<br>      min_node_count = optional(number)<br>      max_node_count = optional(number)<br>    }))<br>    iam       = optional(map(list(string)))<br>    envgroups = optional(list(string))<br>    regions   = optional(list(string))<br>  }))</pre> | `null` | no |
| apigee\_instances | Apigee Instances ([REGION] => [INSTANCE]). | <pre>map(object({<br>    display_name                  = optional(string)<br>    description                   = optional(string, "Terraform-managed")<br>    runtime_ip_cidr_range         = string<br>    troubleshooting_ip_cidr_range = string<br>    disk_encryption_key           = optional(string)<br>    consumer_accept_list          = optional(list(string))<br>  }))</pre> | `null` | no |
| apigee\_org\_description | Description for Apigee Organization. | `string` | `"Apigee Org"` | no |
| apigee\_org\_name | Display name for Apigee Organization. | `string` | `"Apigee Org"` | no |
| billing\_type | Apigee billing type. Can be one of EVALUATION, PAYG, or SUBSCRIPTION. See https://cloud.google.com/apigee/pricing | `string` | `"EVALUATION"` | no |
| create\_apigee\_org | Set to `true` to create a new Apigee org in the provided `var.project_id`; set to `false` to use the existing Apigee org in this project. | `bool` | `true` | no |
| external\_ip | Reserved global external IP for Apigee Load Balancer | `string` | n/a | yes |
| kms\_project\_id | Project ID in which to create keys for Apigee database and disk (org/instance) | `string` | `""` | no |
| network\_id | VPC network ID | `string` | n/a | yes |
| prevent\_key\_destroy | Prevent destroying KMS keys for Apigee Org and Instances | `bool` | `true` | no |
| project\_id | Project id (also used for the Apigee Organization). | `string` | n/a | yes |
| psa\_ranges | Apigee Private Service Access peering ranges | <pre>object({<br>    apigee-range                      = string<br>    google-managed-services-support-1 = string<br>  })</pre> | <pre>{<br>  "apigee-range": "10.0.0.0/22",<br>  "google-managed-services-support-1": "10.1.0.0/28"<br>}</pre> | no |
| runtime\_type | Apigee runtime type. Can be one of CLOUD or HYBRID. | `string` | `"CLOUD"` | no |
| ssl\_certificate | SSL Certificate ID for Apigee Load Balancer | `string` | n/a | yes |
| subnet\_id | Apigee NEG subnet ID | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| apigee\_org\_id | Apigee org ID (same as GCP project ID) |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
