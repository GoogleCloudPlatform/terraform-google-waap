<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| apigee\_envgroups | Apigee Environment Groups. | <pre>map(object({<br>    environments = list(string)<br>    hostnames    = list(string)<br>  }))</pre> | `{}` | no |
| apigee\_environments | Apigee Environment Names. | `list(string)` | `[]` | no |
| apigee\_instances | Apigee Instances (only one for EVAL). | <pre>map(object({<br>    region       = string<br>    ip_range     = string<br>    environments = list(string)<br>  }))</pre> | `{}` | no |
| ax\_region | GCP region for storing Apigee analytics data (see https://cloud.google.com/apigee/docs/api-platform/get-started/install-cli). | `string` | n/a | yes |
| billing\_type | Apigee billing type. Can be one of EVALUATION, PAYG, or SUBSCRIPTION. See https://cloud.google.com/apigee/pricing | `string` | `"EVALUATION"` | no |
| external\_ip | Reserved global external IP for Apigee Load Balancer | `string` | n/a | yes |
| network\_id | VPC network ID | `string` | n/a | yes |
| project\_id | Project id (also used for the Apigee Organization). | `string` | n/a | yes |
| psa\_ranges | Apigee Private Service Access peering ranges | <pre>object({<br>    apigee-range                      = string<br>    google-managed-services-support-1 = string<br>  })</pre> | <pre>{<br>  "apigee-range": "10.0.0.0/22",<br>  "google-managed-services-support-1": "10.1.0.0/28"<br>}</pre> | no |
| ssl\_certificate | SSL Certificate ID for Apigee Load Balancer | `string` | n/a | yes |
| subnet\_id | Apigee NEG subnet ID | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| apigee\_org\_id | Apigee org ID (same as GCP project ID) |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->