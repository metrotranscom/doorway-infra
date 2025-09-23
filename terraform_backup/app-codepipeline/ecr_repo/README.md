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

| Name                                                                                                           | Type     |
| -------------------------------------------------------------------------------------------------------------- | -------- |
| [aws_iam_policy.pull](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy)  | resource |
| [aws_iam_policy.push](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy)  | resource |
| [aws_iam_policy.retag](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |

## Inputs

| Name                                                               | Description                                | Type     | Default | Required |
| ------------------------------------------------------------------ | ------------------------------------------ | -------- | ------- | :------: |
| <a name="input_account"></a> [account](#input_account)             | The account this repository is in          | `string` | n/a     |   yes    |
| <a name="input_name"></a> [name](#input_name)                      | The name of this repository                | `string` | n/a     |   yes    |
| <a name="input_name_prefix"></a> [name_prefix](#input_name_prefix) | An identifier to prepend to resource names | `string` | n/a     |   yes    |
| <a name="input_namespace"></a> [namespace](#input_namespace)       | The namepace for this repository           | `string` | n/a     |   yes    |
| <a name="input_region"></a> [region](#input_region)                | The region this repository is in           | `string` | n/a     |   yes    |

## Outputs

| Name                                                                 | Description |
| -------------------------------------------------------------------- | ----------- |
| <a name="output_policy_arns"></a> [policy_arns](#output_policy_arns) | n/a         |
| <a name="output_url"></a> [url](#output_url)                         | n/a         |

<!-- END_TF_DOCS -->
