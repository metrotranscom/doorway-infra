<!-- BEGIN_TF_DOCS -->

## Requirements

No requirements.

## Providers

| Name                                             | Version |
| ------------------------------------------------ | ------- |
| <a name="provider_aws"></a> [aws](#provider_aws) | n/a     |

## Modules

| Name                                                           | Source     | Version |
| -------------------------------------------------------------- | ---------- | ------- |
| <a name="module_listeners"></a> [listeners](#module_listeners) | ./listener | n/a     |

## Resources

| Name                                                                                         | Type     |
| -------------------------------------------------------------------------------------------- | -------- |
| [aws_lb.nlb](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb) | resource |

## Inputs

| Name                                                                                 | Description                                                    | Type                                                                                                                      | Default | Required |
| ------------------------------------------------------------------------------------ | -------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------- | ------- | :------: |
| <a name="input_additional_tags"></a> [additional_tags](#input_additional_tags)       | Additional tags to apply to NLB resources                      | `map(string)`                                                                                                             | `null`  |    no    |
| <a name="input_alb_arn"></a> [alb_arn](#input_alb_arn)                               | The API ALB                                                    | `string`                                                                                                                  | n/a     |   yes    |
| <a name="input_certificate_arn"></a> [certificate_arn](#input_certificate_arn)       | ARN for the TLS cert                                           | `string`                                                                                                                  | n/a     |   yes    |
| <a name="input_enable_logging"></a> [enable_logging](#input_enable_logging)          | Whether to enable logging on this NLB                          | `bool`                                                                                                                    | `true`  |    no    |
| <a name="input_internal"></a> [internal](#input_internal)                            | Whether this NLB is public or internal                         | `bool`                                                                                                                    | `true`  |    no    |
| <a name="input_listeners"></a> [listeners](#input_listeners)                         | The listeners to create                                        | <pre>map(object({<br> allowed_ips = optional(list(string))<br> allowed_subnets = optional(list(string))<br><br> }))</pre> | n/a     |   yes    |
| <a name="input_log_bucket"></a> [log_bucket](#input_log_bucket)                      | The S3 bucket to write NLB logs to                             | `string`                                                                                                                  | n/a     |   yes    |
| <a name="input_name"></a> [name](#input_name)                                        | The name to give to give to this NLB and its related resources | `string`                                                                                                                  | n/a     |   yes    |
| <a name="input_name_prefix"></a> [name_prefix](#input_name_prefix)                   | The prefix to prepend to resource names                        | `string`                                                                                                                  | n/a     |   yes    |
| <a name="input_security_group_id"></a> [security_group_id](#input_security_group_id) | n/a                                                            | `string`                                                                                                                  | n/a     |   yes    |
| <a name="input_subnet_group"></a> [subnet_group](#input_subnet_group)                | The identifier for the subnet group to place the NLB into      | `string`                                                                                                                  | n/a     |   yes    |
| <a name="input_subnets"></a> [subnets](#input_subnets)                               | A map of the available subnets                                 | <pre>map(list(object({<br> id = string<br> cidr = string<br> })))</pre>                                                   | n/a     |   yes    |
| <a name="input_vpc_id"></a> [vpc_id](#input_vpc_id)                                  | The ID of the VPC to create NLB resources in                   | `string`                                                                                                                  | n/a     |   yes    |

## Outputs

| Name                                                              | Description                           |
| ----------------------------------------------------------------- | ------------------------------------- |
| <a name="output_arn"></a> [arn](#output_arn)                      | n/a                                   |
| <a name="output_dns_name"></a> [dns_name](#output_dns_name)       | n/a                                   |
| <a name="output_listeners"></a> [listeners](#output_listeners)    | n/a                                   |
| <a name="output_log_prefix"></a> [log_prefix](#output_log_prefix) | Used for generating log bucket policy |
| <a name="output_nlb"></a> [nlb](#output_nlb)                      | n/a                                   |
| <a name="output_zone_id"></a> [zone_id](#output_zone_id)          | n/a                                   |

<!-- END_TF_DOCS -->
