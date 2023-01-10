# Web Application and API Protection (WAAP) Blueprint

This repository contains Terraform modules and example configurations to deploy the [Web Application and API Protection (WAAP)](https://cloud.google.com/solutions/web-app-and-api-protection) solution on Google Cloud.


## Usage

Refer to the [JuiceShop Example](./examples/juiceshop_example/) for a functional example deployment of the WAAP solution.

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

## Requirements

These sections describe requirements for using this module.

### Software

The following dependencies must be available:

- [Terraform][terraform] v0.13
- [Terraform Provider for GCP][terraform-provider-gcp] plugin v3.53

### Service Account

A service account with the following roles must be used to provision
the resources of this module:

- Editor `roles/editor`
- reCAPTCHA Enterprise Admin: `roles/recaptchaenterprise.admin`
- Artifact Registry Admin: `roles/artifactregistry.admin`

The [Project Factory module][project-factory-module] and the
[IAM module][iam-module] may be used in combination to provision a
service account with the necessary roles applied.

### APIs

A project with the following APIs enabled must be used to host the
resources of this module:

- Apigee API: `apigee.googleapis.com`
- Artifact Registry API: `artifactregistry.googleapis.com`
- Cloud Build API: `cloudbuild.googleapis.com`
- Cloud KMS API: `cloudkms.googleapis.com`
- Cloud Resource Manager API: `cloudresourcemanager.googleapis.com`
- Compute API: `compute.googleapis.com`
- Data Loss Prevention API: `dlp.googleapis.com`
- Identity and Access Management API: `iam.googleapis.com`
- Cloud Monitoring API: `monitoring.googleapis.com`
- reCAPTCHA Enterprise API: `recaptchaenterprise.googleapis.com`
- Service Networking API: `servicenetworking.googleapis.com`
- Service Usage API: `serviceusage.googleapis.com`

The [Project Factory module][project-factory-module] can be used to
provision a project with the necessary APIs enabled. See [this example](./test/setup/main.tf) for properly configuring project factory to enable these APIs.

## Contributing

Refer to the [contribution guidelines](./CONTRIBUTING.md) for
information on contributing to this module.

[iam-module]: https://registry.terraform.io/modules/terraform-google-modules/iam/google
[project-factory-module]: https://registry.terraform.io/modules/terraform-google-modules/project-factory/google
[terraform-provider-gcp]: https://www.terraform.io/docs/providers/google/index.html
[terraform]: https://www.terraform.io/downloads.html

## Security Disclosures

Please see our [security disclosure process](./SECURITY.md).
