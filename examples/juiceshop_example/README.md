# JuiceShop WAAP Example

This usage example shows how to successfully deploy the WAAP solution to increase security of the [OWASP JuiceShop](https://github.com/juice-shop/juice-shop) application and APIs.

This example deploys:
- Apigee Organization, Instance, Environment Group, Environment
- Apigee configuration (proxy deployment, target server, product, developer, credentials)
- Private Service Connect Network Endpoint Group (NEG)
- Cloud KMS Keyring and Keys
- VPC Network, Subnets, Cloud Router
- Firewall Rules
- GCE Managed Instance Group running JuiceShop application
- HTTPS Load Balancer with Cloud Armor Security Policy
- reCAPTCHA Enterprise Key
- Google Managed SSL Certificates
- Artifact Registry Repository
- BigQuery dataset for log analysis

## Requirements
* A GCP Project with the APIs listed below enabled ([Example](../../test/setup/main.tf))
* Grant your user the permissions outlined below before deploying.
* Run `gcloud auth application-default login` before following the steps below.

### IAM Permissions

The user or service account deploying this example must have the following IAM roles:

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

## Setup

To deploy this example:

### Build the infrastructure
1. Clone `waap` repo
```sh
git clone https://github.com/GoogleCloudPlatform/terraform-google-waap.git
```
2. Change to `juiceshop_example` directory:
```sh
cd terraform-google-waap/examples/juiceshop_example
```
3. Run `terraform init` from within this example directory.
```sh
terraform init
```
4. (Optional) Create a `terraform.tfvars` file to provide values for `project_id` and optionally `region`.

5. Run `terraform apply` within this example directory. If you skipped step 4, you may be prompted for the `project_id` value at this stage. Deployment may take up to 60 minutes.

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| project\_id | GCP Project ID in which to create example resources | `string` | n/a | yes |
| region | Region in which to create regional resources. | `string` | `"us-central1"` | no |

## Outputs

No outputs.

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
