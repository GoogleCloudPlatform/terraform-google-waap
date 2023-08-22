# Web App Protection Example - Managed Instance Group Backend

This usage example shows how to successfully deploy a terraform-based infrastructure contemplating the use of Cloud CDN and Cloud Armor tools. These tools are deployed with predefined rules to protect an environment of Web applications hosted in Managed Instance Groups using the Global Load Balancer.

Additionally, we included infrastructure pipeline examples to facilitate the adoption of the model in environments that already used Jenkins, Gitlab CI and Cloud Build as a CI/CD tool for infrastructure solutions.

## This example deploys:

-   VPC Network, Subnets, Cloud Router
-   Firewall Rules
-   GCE Managed Instance Group running Sample application
-   Global Load Balancer
-   Cloud CDN with some security best practices
-   Cloud Armor with top 10 OWASP Rules and reCAPTCHA integration
-   Traffic Management

## Requirements

-   A GCP Project containing the enabled APIs listed in this document.
-   All the permissions outlined later on this document must be granted to the users.
-   Run gcloud auth application-default login before following the step by step instructions below.

## IAM Permissions

-   The user or service account deploying this example must have the following IAM roles:Owner roles/owner
-   reCAPTCHA Enterprise Admin: roles/recaptchaenterprise.admin
-   Artifact Registry Admin: roles/artifactregistry.admin

## APIs

A project with the following APIs enabled must be used to host the resources of this module:

-   Cloud Resource Manager API: cloudresourcemanager.googleapis.com
-   Compute API: compute.googleapis.com
-   Identity and Access Management API: iam.googleapis.com
-   Cloud Monitoring API: monitoring.googleapis.com
-   reCAPTCHA Enterprise API: recaptchaenterprise.googleapis.com
-   Service Networking API: servicenetworking.googleapis.com
-   Service Usage API: serviceusage.googleapis.com

## Setup

Here's a step by step to deploy and test this example:

### Build the infrastructure

1.  Clone waap repo

	```git clone``` [https://github.com/GoogleCloudPlatform/terraform-google-waap.git](https://github.com/GoogleCloudPlatform/terraform-google-waap.git)

2.  Change to web-app-protection-example directory:

    ```cd terraform-google-waap/examples/web-app-protection-example```

3.  Run terraform init from within this example directory.

    ```terraform init```

Note: The "project_id" is the only variable that must be changed. Any other local value change is optional.

5.  Run terraform plan and check the prompt output.

    ```terraform plan```

6.  Run terraform apply within this example directory.

    ```terraform apply```

## Optional

Some features are optional, are not created by default and are enabled based on their variables.

An example is the URL map feature, used to forward HTTP(S) requests to backend services.

If you need to perform traffic splitting between your backends, just set the `url_map` variable to `true` and configure the 'google_compute_url_map' resource.

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| project\_id | Google Project ID in which the resources will be created. | `string` | n/a | yes |
| url\_map | Enable or disable the 'google\_compute\_url\_map' feature to route requests to backends based on rules. | `bool` | `false` | no |

## Outputs

No outputs.

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
