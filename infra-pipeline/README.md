# Infrastructure Pipeline

The `infra-pipeline` project creates the pipeline that automates deployment of changes to infrastructure. This is most commonly used to manage changes to Bloom infrastructure, but could also be used to automate changes to the base infra (after initial setup) or the app pipeline.

Note that while the app pipeline makes use of the pipeline module under `modules/pipeline`, this project predates that module and has not yet been updated to make use of it.

## Deployment

To create a new pipeline, you will first want to create a new Terraform workspace in this directory with the name of the environment you are creating and/or the infrastructure being managed (ie `terraform workspace new bloom-infra-prod`) and a copy of the tfvars template named after the environment (ie `bloom-infra-prod.tfvars`)\*. Here are some sample names you might consider:

- bloom-infra -> the only Bloom instance pipeline
- prod -> another way to say the only Bloom instance pipeline
- bloom-infra-nonprod -> the pipeline that builds the Bloom infra in the non-production environments
- bloom-infra-prod -> the pipeline that builds the Bloom infra in the production environments
- setup-dev -> the pipeline that updates the base infra in the dev environment

Note that, due to some internal dependencies, the pipeline must be deployed in a two step process; one step to setup some IAM policies and another to deploy the rest of the infra. This additional step should only be needed when first creating the pipeline.

A sample flow to create an environment named "bloom-infra-prod" might look something like this:

1. `terraform workspace new bloom-infra-prod`
2. `cp tfvars.template bloom-infra-prod.tfvars`
3. Edit tfvars file to add desired configuration
4. Run `terraform apply -var-file bloom-infra-prod.tfvars -target module.pipeline.aws_iam_policy.codebuild_artifacts` to create IAM resources
5. Visually validate resource changes and ensure there are no permissions issues
6. Type "yes" to apply changes
7. Run `terraform apply -var-file bloom-infra-prod.tfvars` to create the rest of the resources

# Terraform Docs

<!-- Do not edit below this line! -->
<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 5.0 |

## Providers

No providers.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_pipeline"></a> [pipeline](#module\_pipeline) | ./pipeline | n/a |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | The AWS region to use when deploying regional resources | `string` | n/a | yes |
| <a name="input_codestar_connection_arn"></a> [codestar\_connection\_arn](#input\_codestar\_connection\_arn) | The ARN for the CodeStar Connection to use | `string` | n/a | yes |
| <a name="input_owner"></a> [owner](#input\_owner) | The owner of the resources created via these templates | `string` | n/a | yes |
| <a name="input_pipeline"></a> [pipeline](#input\_pipeline) | n/a | <pre>object({<br>    name = string<br>    # See ./pipeline/inputs.tf for object structures<br>    tf_root             = any<br>    sources             = any<br>    environments        = any<br>    notification_topics = any<br>    notify              = any<br>  })</pre> | n/a | yes |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | A project-specific identifier prepended to resource names | `string` | n/a | yes |
| <a name="input_project_name"></a> [project\_name](#input\_project\_name) | Name of the project | `string` | n/a | yes |

## Outputs

No outputs.
<!-- END_TF_DOCS -->
