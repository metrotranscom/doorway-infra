<!-- BEGIN_TF_DOCS -->

## Requirements

No requirements.

## Providers

| Name                                             | Version |
| ------------------------------------------------ | ------- |
| <a name="provider_aws"></a> [aws](#provider_aws) | n/a     |

## Modules

No modules.

## Resources

| Name                                                                                                                                | Type     |
| ----------------------------------------------------------------------------------------------------------------------------------- | -------- |
| [aws_ecr_repository.repo](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecr_repository)               | resource |
| [aws_ecr_repository_policy.repo](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecr_repository_policy) | resource |

## Inputs

| Name                                                                        | Description                                                          | Type     | Default | Required |
| --------------------------------------------------------------------------- | -------------------------------------------------------------------- | -------- | ------- | :------: |
| <a name="input_name"></a> [name](#input_name)                               | The name to give to give to this ECR repo and its related resources  | `string` | n/a     |   yes    |
| <a name="input_name_prefix"></a> [name_prefix](#input_name_prefix)          | The prefix to prepend to resource names                              | `string` | n/a     |   yes    |
| <a name="input_scan_images"></a> [scan_images](#input_scan_images)          | Whether to scan images pushed to the ECR repo                        | `bool`   | `false` |    no    |
| <a name="input_source_account"></a> [source_account](#input_source_account) | The ID of the account where images will be pushed and/or pulled from | `string` | n/a     |   yes    |

## Outputs

| Name                                         | Description |
| -------------------------------------------- | ----------- |
| <a name="output_arn"></a> [arn](#output_arn) | n/a         |
| <a name="output_url"></a> [url](#output_url) | n/a         |

<!-- END_TF_DOCS --><!-- BEGIN_TF_DOCS -->

## Requirements

No requirements.

## Providers

| Name                                             | Version |
| ------------------------------------------------ | ------- |
| <a name="provider_aws"></a> [aws](#provider_aws) | n/a     |

## Modules

No modules.

## Resources

| Name                                                                                                                                | Type     |
| ----------------------------------------------------------------------------------------------------------------------------------- | -------- |
| [aws_ecr_repository.repo](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecr_repository)               | resource |
| [aws_ecr_repository_policy.repo](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecr_repository_policy) | resource |

## Inputs

| Name                                                                        | Description                                                          | Type     | Default | Required |
| --------------------------------------------------------------------------- | -------------------------------------------------------------------- | -------- | ------- | :------: |
| <a name="input_name"></a> [name](#input_name)                               | The name to give to give to this ALB and its related resources       | `string` | n/a     |   yes    |
| <a name="input_name_prefix"></a> [name_prefix](#input_name_prefix)          | The prefix to prepend to resource names                              | `string` | n/a     |   yes    |
| <a name="input_scan_images"></a> [scan_images](#input_scan_images)          | Whether to scan images pushed to the ECR repo                        | `bool`   | `false` |    no    |
| <a name="input_source_account"></a> [source_account](#input_source_account) | The ID of the account where images will be pushed and/or pulled from | `string` | n/a     |   yes    |

## Outputs

| Name                                         | Description |
| -------------------------------------------- | ----------- |
| <a name="output_arn"></a> [arn](#output_arn) | n/a         |
| <a name="output_url"></a> [url](#output_url) | n/a         |

<!-- END_TF_DOCS -->
