# Doorway Infrastructure Templates

This repository contains Terraform templates for deploying AWS infrastructure used by the Doorway Housing Project. It is broken up into 4 Terraform projects, each responsible for one aspect of the environment, and an addtional set of shared modules.

# Terraform Workspaces

All resources created by each project are namespaced based on the `project_id` var and the environment name (primarily defined by `terraform.workspace`), so it is important to use a different workspace for each environment to avoid conflicts. Applying changes to the "test" environment, for example, may look something like this:

```
terraform workspace select test
terraform apply -var-file test.tfvars
```

It is a good idea to verify which workspace you are in using `terraform workspace show` before applying any big changes, especially if you have been switching back and forth between multiple environments. The output of the `terraform apply` command will includes something like this in the output:

```
Do you want to perform these actions in workspace "prod"?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value:
```

_Always_ make sure that the workspace name matches the name of the environment you want to deploy into before approving. It is for this reason that using the auto-approve flag is highly discouraged.

# Creating a new environment

## Setup

To get started with a new environment, first deploy the infrastructure in the Setup project. You find find directions to do this within the `setup` directory.

## App Pipeline

Once the base infrastructure has been created, create or update the app pipeline to start building Docker images for the Bloom services following the directions under `app-codepipeline`. You will need the ECR repo information from the output of the setup deployment to configure the pipeline correctly. Follow the directions in the `app-code-pipeline` directory to set this up.

Any deployment steps (migration, update ECS, etc) will fail prior to the Bloom instance being created. This won't hurt anything, but you can avoid this by leaving those steps out for now and then adding them back in after the rest of the infra has been created. Alternatively, you can start with the Bloom instance, but be aware that the services will thrash until the app pipeline builds the images they need. This also shouldn't pose much of a problem, so choose whichever starting point you feel most comfrotable with.

## Bloom Instance

Next, create a tfvars file for the Bloom infrastructure in this environment. At this point you can create the Bloom infra in this environment by deploying manually or by letting the infra pipeline handle it. While this infrastructure can and should be managed via the infra pipeline in the long term, doing the initial setup manually can often be easier, especially if any issues (usually IAM-related or due to invalid configuration options) arise. To deploy manually, just follow the directions for manual deployment under the `bloom-instance` directory, otherwise skip to the next step.

Make note of the network information (VPC ID and app subnet IDs) and database secret ARN from the outputs once created, as you will need these for the app pipeline. If you already deployed the app pipeline, add this information into your tfvars file and reapply to update.

## Infra Pipeline

Commit and merge the tfvars file for the new Bloom infra into whatever repository it's being kept in. Create a pipeline for deploying the Bloom instance infrastructure using the directions in the `infra-pipeline` directory. If the pipeline was previously created, just add the new environment to the existing pipeline tfvars file and apply the changes. Re-run the pipeline off the commit with the merged tfvars file, and monitor for any errors.
