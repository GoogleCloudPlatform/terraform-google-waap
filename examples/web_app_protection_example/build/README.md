### Cloud Build

If you intend to use Cloud Build as your infrastructure CI/CD Tool, we created a [Cloud Build](cloudbuild.yaml) example with a pipeline suggestion for this environment. Please, refer to the [Cloud Build](cloudbuild.yaml) to view the example.

- Requirements

1.  Cloud Build API Enabled.
2.  You can use the default Cloud Build service account or a service account dedicated to terraform, as long as it has the necessary permissions.
3.  A dedicated bucket to store the terraform state file.
4.  At the time of creating the Cloud Build trigger set the substitution variable "_STATE_BUCKET_NAME" with the name of the terraform state bucket.

- Cloud Buid file rules and conditions

This [Cloud Build](.cloudbuild.yaml) contains rules based on branch names considering two different behavior:

1.  Behavior 1: this behavior happens when the code is pushed to a branch with the same name as an environment folder inside web-app-protection-example/environments/ (E.g., "prd", "dev"or "npd" ).

For this condition, the pipeline code will run steps related to terraform init and terraform apply. When working with multiple environments, it’s really important to change the values of the variables inside the terraform.tfvars files for each environment in order to avoid conflicts.

2.  Behavior 2: differently from behavior 1, this behavior happens when the branch name doesn't match an environment folder name. 

For this condition, the pipeline code will run steps related to terraform init and terraform plan, generating a plan output without changing your infrastructure.