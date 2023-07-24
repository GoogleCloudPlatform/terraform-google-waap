<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| ca\_policy\_name | Name of Cloud Armor Security Policy resource | `string` | n/a | yes |
| dataset\_name | Name of BigQuery dataset where WAAP analytics will be stored | `string` | `"waap_analytics"` | no |
| log\_sink\_name | Name of BigQuery log sink | `string` | `"WAAP_log_sink"` | no |
| project\_id | GCP Project ID in which analytics resources will be created | `string` | n/a | yes |
| sa\_name | Name of service account with BigQuery access to be used by Looker for dashboarding | `string` | `"waap-bq-sa"` | no |

## Outputs

No outputs.

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
