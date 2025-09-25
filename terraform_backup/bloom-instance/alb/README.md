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

| Name                                                                                         | Type     |
| -------------------------------------------------------------------------------------------- | -------- |
| [aws_lb.alb](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb) | resource |

## Inputs

| Name                                                                                 | Description                                                    | Type                                                                                                                                                                                                | Default | Required |
| ------------------------------------------------------------------------------------ | -------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------- | :------: |
| <a name="input_additional_tags"></a> [additional_tags](#input_additional_tags)       | Additional tags to apply to ALB resources                      | `map(string)`                                                                                                                                                                                       | `null`  |    no    |
| <a name="input_cert_map"></a> [cert_map](#input_cert_map)                            | ARNs for TLS certificates to apply to secure listeners         | `map(string)`                                                                                                                                                                                       | n/a     |   yes    |
| <a name="input_enable_logging"></a> [enable_logging](#input_enable_logging)          | Whether to enable logging on this ALB                          | `bool`                                                                                                                                                                                              | `true`  |    no    |
| <a name="input_internal"></a> [internal](#input_internal)                            | Whether this ALB is public or internal                         | `bool`                                                                                                                                                                                              | `false` |    no    |
| <a name="input_listeners"></a> [listeners](#input_listeners)                         | The listeners to create                                        | <pre>map(object({<br> port = number<br> default_action = string<br><br> allowed_ips = optional(list(string))<br> allowed_subnets = optional(list(string))<br><br> tls = optional(any)<br> }))</pre> | n/a     |   yes    |
| <a name="input_log_bucket"></a> [log_bucket](#input_log_bucket)                      | The S3 bucket to write ALB logs to                             | `string`                                                                                                                                                                                            | n/a     |   yes    |
| <a name="input_name"></a> [name](#input_name)                                        | The name to give to give to this ALB and its related resources | `string`                                                                                                                                                                                            | n/a     |   yes    |
| <a name="input_name_prefix"></a> [name_prefix](#input_name_prefix)                   | The prefix to prepend to resource names                        | `string`                                                                                                                                                                                            | n/a     |   yes    |
| <a name="input_security_group_id"></a> [security_group_id](#input_security_group_id) | n/a                                                            | `string`                                                                                                                                                                                            | n/a     |   yes    |
| <a name="input_subnet_group"></a> [subnet_group](#input_subnet_group)                | The identifier for the subnet group to place the ALB into      | `string`                                                                                                                                                                                            | n/a     |   yes    |
| <a name="input_subnets"></a> [subnets](#input_subnets)                               | A map of the available subnets                                 | <pre>map(list(object({<br> id = string<br> cidr = string<br> })))</pre>                                                                                                                             | n/a     |   yes    |
| <a name="input_vpc_id"></a> [vpc_id](#input_vpc_id)                                  | The ID of the VPC to create ALB resources in                   | `string`                                                                                                                                                                                            | n/a     |   yes    |

## Outputs

| Name                                                              | Description                           |
| ----------------------------------------------------------------- | ------------------------------------- |
| <a name="output_alb"></a> [alb](#output_alb)                      | n/a                                   |
| <a name="output_arn"></a> [arn](#output_arn)                      | n/a                                   |
| <a name="output_dns_name"></a> [dns_name](#output_dns_name)       | n/a                                   |
| <a name="output_log_prefix"></a> [log_prefix](#output_log_prefix) | Used for generating log bucket policy |
| <a name="output_zone_id"></a> [zone_id](#output_zone_id)          | n/a                                   |

<!-- END_TF_DOCS -->
