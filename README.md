# terraform-google-waap

This repository contains Terraform modules and eample configurations to deploy the [Web Application and API Protection (WAAP)](https://cloud.google.com/solutions/web-app-and-api-protection) solution on Google Cloud.  


## Usage

Basic usage of this module is as follows:

```hcl
module "waap" {
  source  = "terraform-google-modules/waap/google"
  version = "~> 0.1"

  project_id  = "<PROJECT ID>"
  bucket_name = "gcs-test-bucket"
}
```

Functional examples are included in the
[examples](./examples/) directory.

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| gcs-bucket-name | n/a | `string` | `"juiceshop-code"` | no |
| project\_id | project id required | `string` | n/a | yes |
| regions | List of regions (support for multi-region deployment) | <pre>list(object({<br>    region = string<br>    cidr   = string<br>    })<br>  )</pre> | <pre>[<br>  {<br>    "cidr": "10.0.32.0/20",<br>    "region": "us-east1"<br>  }<br>]</pre> | no |
| services\_to\_enable | List of GCP Services to enable | `list(string)` | <pre>[<br>  "compute.googleapis.com",<br>  "iap.googleapis.com",<br>  "apigee.googleapis.com",<br>  "cloudresourcemanager.googleapis.com",<br>  "cloudbuild.googleapis.com",<br>  "iam.googleapis.com",<br>  "logging.googleapis.com",<br>  "monitoring.googleapis.com",<br>  "compute.googleapis.com",<br>  "serviceusage.googleapis.com",<br>  "stackdriver.googleapis.com",<br>  "servicemanagement.googleapis.com",<br>  "servicecontrol.googleapis.com",<br>  "storage.googleapis.com",<br>  "servicenetworking.googleapis.com",<br>  "cloudkms.googleapis.com",<br>  "containerregistry.googleapis.com",<br>  "run.googleapis.com",<br>  "recaptchaenterprise.googleapis.com",<br>  "artifactregistry.googleapis.com"<br>]</pre> | no |
| vpc-name | Custom VPC Name | `string` | `"apigee-waap-demo"` | no |

## Outputs

No output.

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

## Requirements

These sections describe requirements for using this module.

### Software

The following dependencies must be available:

- [Terraform][terraform] v0.13
- [Terraform Provider for GCP][terraform-provider-gcp] plugin v3.0

### Service Account

A service account with the following roles must be used to provision
the resources of this module:

- Storage Admin: `roles/storage.admin`

The [Project Factory module][project-factory-module] and the
[IAM module][iam-module] may be used in combination to provision a
service account with the necessary roles applied.

### APIs

A project with the following APIs enabled must be used to host the
resources of this module:

- Google Cloud Storage JSON API: `storage-api.googleapis.com`

The [Project Factory module][project-factory-module] can be used to
provision a project with the necessary APIs enabled.

## Contributing

Refer to the [contribution guidelines](./CONTRIBUTING.md) for
information on contributing to this module.

[iam-module]: https://registry.terraform.io/modules/terraform-google-modules/iam/google
[project-factory-module]: https://registry.terraform.io/modules/terraform-google-modules/project-factory/google
[terraform-provider-gcp]: https://www.terraform.io/docs/providers/google/index.html
[terraform]: https://www.terraform.io/downloads.html

## Security Disclosures

Please see our [security disclosure process](./SECURITY.md).
