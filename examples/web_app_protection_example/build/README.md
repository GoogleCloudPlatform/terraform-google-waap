# Web App Protection Example - CI/CD Tools build example

In this folder we include examples of descriptive files for pipelines for CI/CD tools.

The files are divided into groups of two different functionalities:

1.  The first group is the files where we describe the steps of the pipelines of each CI/CD tool.

2.  The second group is a group of common files between the pipeles, where the terraform functions and commands that will be used are described.

Segmenting in this way, we make it possible to have a centralized point for changes to pipeline-functions.sh file functions so that whenever a new CI/CD tool is included in the environment, it will not be necessary to rewrite the functions, just create the steps of the new one CI/CD tool calling the pipeline-functions.sh file that already has all functions and conditions duly declared.

## Examples already created:

### Jenkins

If you already have a Jenkins environment to run your terraform code or if you intend to use Jenkins as your infrastructure CI/CD Tool, we created a [JenkinsFile](Jenkinsfile) example with a pipeline suggestion for this environment. Please, refer to the [JenkinsFile](Jenkinsfile) to view the example.

- Requirements

1. [Jenkins installed and running](https://www.jenkins.io/doc/book/installing/)

2. [Jenkins git plugin installed and running](https://plugins.jenkins.io/git/)

3. [Terraform installed in the Jenkins instance](https://developer.hashicorp.com/terraform/tutorials/gcp-get-started/install-cli)

- Jenkins file rules and conditions

This jenkins file contains rules based on branch names considering two different behavior:

1.  Behavior 1: this behavior happens when the code is pushed to a branch with the same name as an environment folder inside web-app-protection-example/environments/ (E.g., "prd", "dev"or "npd" ).

For this condition, the pipeline code will run steps related to terraform init and terraform apply. When working with multiple environments, it’s really important to change the values of the variables inside the terraform.tfvars files for each environment in order to avoid conflicts.

2.  Behavior 2: differently from behavior 1, this behavior happens when the branch name doesn't match an environment folder name.

For this condition, the pipeline code will run steps related to terraform init and terraform plan, generating a plan output without changing your infrastructure.

### Gitlab

If you already have a Gitlab environment to run your terraform code or if you intend to use Jenkins as your infrastructure CI/CD Tool, we created a [Gitlab-ci](.gitlab-ci.yml) example with a pipeline suggestion for this environment. Please, refer to the [Gitlab-ci](.gitlab-ci.yml) to view the example.

- Requirements

1.  Gitlab installed and running
2.  A dedicated service account to terraform perform actions in the environment with owner permissions in the target project
3.  A dedicated bucket to store the terraform state file
4.  Change the variables "TF_SA_EMAIL" and "STATE_BUCKET_NAME" with the terraform service account email and the terraform state bucket name.

- Gitlab-ci file rules and conditions

This [Gitlab-ci](.gitlab-ci.yml) contains rules based on branch names considering two different behavior:

1.  Behavior 1: this behavior happens when the code is pushed to a branch with the same name as an environment folder inside web-app-protection-example/environments/ (E.g., "prd", "dev"or "npd" ).

For this condition, the pipeline code will run steps related to terraform init and terraform apply. When working with multiple environments, it’s really important to change the values of the variables inside the terraform.tfvars files for each environment in order to avoid conflicts.

2.  Behavior 2: differently from behavior 1, this behavior happens when the branch name doesn't match an environment folder name.

For this condition, the pipeline code will run steps related to terraform init and terraform plan, generating a plan output without changing your infrastructure.

### Cloud Build

If you intend to use Cloud Build as your infrastructure CI/CD Tool, we created a [Cloud Build](cloudbuild.yaml) example with a pipeline suggestion for this environment. Please, refer to the [Cloud Build](cloudbuild.yaml) to view the example.

- Requirements

1.  Cloud Build API Enabled.
2.  You can use the default Cloud Build service account or a service account dedicated to terraform, as long as it has the necessary permissions.
3.  A dedicated bucket to store the terraform state file.
4.  At the time of creating the Cloud Build trigger set the substitution variable "_STATE_BUCKET_NAME" with the name of the terraform state bucket.

- Cloud Buid file rules and conditions

This [Cloud Build](cloudbuild.yaml) contains rules based on branch names considering two different behavior:

1.  Behavior 1: this behavior happens when the code is pushed to a branch with the same name as an environment folder inside web-app-protection-example/environments/ (E.g., "prd", "dev"or "npd" ).

For this condition, the pipeline code will run steps related to terraform init and terraform apply. When working with multiple environments, it’s really important to change the values of the variables inside the terraform.tfvars files for each environment in order to avoid conflicts.

2.  Behavior 2: differently from behavior 1, this behavior happens when the branch name doesn't match an environment folder name.

For this condition, the pipeline code will run steps related to terraform init and terraform plan, generating a plan output without changing your infrastructure.
