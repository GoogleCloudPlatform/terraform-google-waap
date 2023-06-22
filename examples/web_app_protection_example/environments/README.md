# Multi-environment strategy

In addition to the option of using the single environment as referenced in the readme file in the previous folder, the option of multiple environments also applies to this solution.

Here we have the options to deploy the solutions by segmenting environments, with a small adjustment in the step-by-step execution where we will inform terraform a file of variables and also a customized backend located inside the folder of each environment (in this example folder, we have dev and prd).

Therefore, we will maintain the same steps of the single environment strategy, adding the environment indicators in the appropriate steps defining which will be the variables file used (only project_id is mandatory) and which will be the backend configuration.


## Setup

Here's a step by step to deploy and test this example using multi-environment:

### Build the infrastructure (example using the DEV environment)

1.  Clone waap repo

	```git clone [https://github.com/GoogleCloudPlatform/terraform-google-waap.git](https://github.com/GoogleCloudPlatform/terraform-google-waap.git)```

2.  Change to web_app_protection_example directory:

    ```cd terraform-google-waap/examples/web_app_protection_example```

2.1 Rename the file terraform.tfvars.example to terraform.tfvars

    ```mv -v environments/dev/terraform.tfvars.example environments/dev/terraform.tfvars```

3.  Run terraform init from within this example directory.
    
    ```terraform init -backend-config=environments/dev/backend.tf```

4.  Change the terraform.tfvars file values, including values related to your environment.
  
Note: The "project_id" is the only variable that must be changed. Any other variable change is optional.

5.  Run terraform plan and check the prompt output.
  
    ```terraform plan -var-file="environments/dev/terraform.tfvars"```

6.  Run terraform apply within this example directory.

    ```terraform apply -var-file="environments/dev/terraform.tfvars"```

### * Note that we are using the dev environment as a example. You can change from "dev" to "prd" or personalize the environment name according to your needs.
