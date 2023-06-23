The infra-pipeline project creates the pipeline that automates deployment of changes to the Bloom infrastructure across all environments.

<!-- Do not edit below this line! -->
<!-- BEGIN_TF_DOCS -->

## Requirements

| Name                                                                     | Version   |
| ------------------------------------------------------------------------ | --------- |
| <a name="requirement_terraform"></a> [terraform](#requirement_terraform) | >= 1.3    |
| <a name="requirement_aws"></a> [aws](#requirement_aws)                   | ~> 4.57.0 |

## Providers

No providers.

## Modules

| Name                                                        | Source     | Version |
| ----------------------------------------------------------- | ---------- | ------- |
| <a name="module_pipeline"></a> [pipeline](#module_pipeline) | ./pipeline | n/a     |

## Resources

No resources.

## Inputs

| Name                                                                                                   | Description                                               | Type                                                                                                                                                                                                        | Default | Required |
| ------------------------------------------------------------------------------------------------------ | --------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------- | :------: |
| <a name="input_aws_region"></a> [aws_region](#input_aws_region)                                        | The AWS region to use when deploying regional resources   | `string`                                                                                                                                                                                                    | n/a     |   yes    |
| <a name="input_codestar_connection_arn"></a> [codestar_connection_arn](#input_codestar_connection_arn) | The ARN for the CodeStar Connection to use                | `string`                                                                                                                                                                                                    | n/a     |   yes    |
| <a name="input_owner"></a> [owner](#input_owner)                                                       | The owner of the resources created via these templates    | `string`                                                                                                                                                                                                    | n/a     |   yes    |
| <a name="input_pipeline"></a> [pipeline](#input_pipeline)                                              | n/a                                                       | <pre>object({<br> name = string<br> # See ./pipeline/inputs.tf for object structures<br> tf_root = any<br> sources = any<br> environments = any<br> notification_topics = any<br> notify = any<br> })</pre> | n/a     |   yes    |
| <a name="input_project_id"></a> [project_id](#input_project_id)                                        | A project-specific identifier prepended to resource names | `string`                                                                                                                                                                                                    | n/a     |   yes    |
| <a name="input_project_name"></a> [project_name](#input_project_name)                                  | Name of the project                                       | `string`                                                                                                                                                                                                    | n/a     |   yes    |

## Outputs

No outputs.

<!-- END_TF_DOCS -->
