# Web App Protection Example - Managed Instance Group Backend

This usage example shows how to successfully deploy a terraform-based infrastructure contemplating the use of Cloud CDN and Cloud Armor tools. These tools are deployed with predefined rules to protect an environment of Web applications hosted in Managed Instance Groups using the Global Load Balancer.

Additionally, we include an example of an infrastructure pipeline using Jenkins to facilitate the adoption of the model in environments that already use Jenkins as a CI/CD tool for infrastructure solutions.

## This example deploys:

-   VPC Network, Subnets, Cloud Router
-   Firewall Rules
-   GCE Managed Instance Group running Sample application
-   Global Load Balancer with Managed Instance Groups in 2 regions
-   Cloud CDN with some security best practices
-   Cloud Armor with top 10 OWASP Rules and reCAPTCHA integration

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

	```git clone [https://github.com/GoogleCloudPlatform/terraform-google-waap.git](https://github.com/GoogleCloudPlatform/terraform-google-waap.git)```

2.  Change to web-app-protection-example directory:

    ```cd terraform-google-waap/examples/web-app-protection-example```

3.  Run terraform init from within this example directory.

    ```terraform init```

4. Rename the terraform.tfvars.examples to terraform.tfvars and edit the variable values, including values related to your environment.

    ```mv terraform.tfvars.examples terraform.tfvars```

Note: The "project_id" is the only variable that must be changed. Any other variable change is optional.

5.  Run terraform plan and check the prompt output.

    ```terraform plan```

6.  Run terraform apply within this example directory.

    ```terraform apply```

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| backend\_port | value | `number` | `80` | no |
| base\_instance\_name\_r1 | The base instance name to use for instances in this group. | `string` | `"mig-backend-r1-vm"` | no |
| base\_instance\_name\_r2 | The base instance name to use for instances in this group. | `string` | `"mig-backend-r2-vm"` | no |
| disk\_size\_gb\_r1 | The size of the image in gigabytes. If not specified, it will inherit the size of its base image. | `string` | `"100"` | no |
| disk\_size\_gb\_r2 | The size of the image in gigabytes. If not specified, it will inherit the size of its base image. | `string` | `"100"` | no |
| enable\_cdn | value | `bool` | `true` | no |
| machine\_type\_r1 | Machine type to create, e.g. n1-standard-1 | `string` | `"e2-small"` | no |
| machine\_type\_r2 | Machine type to create, e.g. n1-standard-1 | `string` | `"e2-small"` | no |
| mig\_name\_r1 | Name of the managed instance group. | `string` | `"mig-backend-r1"` | no |
| mig\_name\_r2 | Name of the managed instance group. | `string` | `"mig-backend-r2"` | no |
| name\_prefix\_r1 | Name prefix for the instance template | `string` | `"vm-template-"` | no |
| name\_prefix\_r2 | Name prefix for the instance template | `string` | `"vm-template-"` | no |
| network\_name\_r1 | VPC network name | `string` | `"webapp-r1"` | no |
| network\_name\_r2 | VPC network name | `string` | `"webapp-r2"` | no |
| project\_id | Google Project ID | `string` | `"ci-waap-a106"` | no |
| region\_r1 | Region in which to create resources | `string` | `"us-central1"` | no |
| region\_r2 | Region in which to create resources | `string` | `"us-east1"` | no |
| service\_account\_id\_r1 | The account ID used to generate the virtual machine service account. | `string` | `"sa-backend-vm-r1"` | no |
| service\_account\_id\_r2 | The account ID used to generate the virtual machine service account. | `string` | `"sa-backend-vm-r2"` | no |
| service\_account\_roles\_r1 | Permissions to be added to the created service account. | `list(string)` | <pre>[<br>  "roles/monitoring.metricWriter",<br>  "roles/logging.logWriter"<br>]</pre> | no |
| service\_account\_roles\_r2 | Permissions to be added to the created service account. | `list(any)` | <pre>[<br>  "roles/monitoring.metricWriter",<br>  "roles/logging.logWriter"<br>]</pre> | no |
| service\_account\_scopes\_r1 | List of scopes for the instance template service account | `list(any)` | <pre>[<br>  "logging-write",<br>  "monitoring-write",<br>  "cloud-platform"<br>]</pre> | no |
| service\_account\_scopes\_r2 | List of scopes for the instance template service account | `list(any)` | <pre>[<br>  "logging-write",<br>  "monitoring-write",<br>  "cloud-platform"<br>]</pre> | no |
| source\_image\_r1 | Image used for compute VMs. | `string` | `"debian-cloud/debian-11"` | no |
| source\_image\_r2 | Image used for compute VMs. | `string` | `"debian-cloud/debian-11"` | no |
| subnet\_ip\_r1 | This is th IP of your subnet | `string` | `"10.0.16.0/24"` | no |
| subnet\_ip\_r2 | This is th IP of your subnet | `string` | `"10.0.32.0/24"` | no |
| subnet\_name\_r1 | Subnet name | `string` | `"webapp-r1"` | no |
| subnet\_name\_r2 | Subnet name | `string` | `"webapp-r2"` | no |
| subnet\_region\_r1 | Subnet Region | `string` | `"us-central1"` | no |
| subnet\_region\_r2 | Subnet Region | `string` | `"us-east1"` | no |
| tags\_r1 | Network tags, provided as a list | `list(string)` | <pre>[<br>  "backend-r1"<br>]</pre> | no |
| tags\_r2 | Network tags, provided as a list | `list(string)` | <pre>[<br>  "backend-r2"<br>]</pre> | no |
| target\_size\_r1 | The target number of running instances for this managed instance group. This value should always be explicitly set unless this resource is attached to an autoscaler, in which case it should never be set. | `number` | `1` | no |
| target\_size\_r2 | The target number of running instances for this managed instance group. This value should always be explicitly set unless this resource is attached to an autoscaler, in which case it should never be set. | `number` | `1` | no |
| zone\_r1 | value | `string` | `"us-central1-b"` | no |
| zone\_r2 | value | `string` | `"us-east1-b"` | no |

## Outputs

No outputs.

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
