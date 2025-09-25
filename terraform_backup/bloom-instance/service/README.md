<!-- BEGIN_TF_DOCS -->

## Requirements

No requirements.

## Providers

No providers.

## Modules

| Name                                                     | Source         | Version |
| -------------------------------------------------------- | -------------- | ------- |
| <a name="module_service"></a> [service](#module_service) | ../ecs/service | n/a     |
| <a name="module_task"></a> [task](#module_task)          | ../ecs/task    | n/a     |

## Resources

No resources.

## Inputs

| Name                                                                                 | Description                                                  | Type                                                                                            | Default | Required |
| ------------------------------------------------------------------------------------ | ------------------------------------------------------------ | ----------------------------------------------------------------------------------------------- | ------- | :------: |
| <a name="input_additional_tags"></a> [additional_tags](#input_additional_tags)       | Additional tags to apply to service resources                | `map(string)`                                                                                   | `null`  |    no    |
| <a name="input_alb_map"></a> [alb_map](#input_alb_map)                               | The available ALBs                                           | <pre>map(object({<br> arn = string<br> dns_name = string<br> zone_id = string<br><br> }))</pre> | n/a     |   yes    |
| <a name="input_cert_map"></a> [cert_map](#input_cert_map)                            | ARNs for TLS certificates to apply to secure listeners       | `map(string)`                                                                                   | n/a     |   yes    |
| <a name="input_cloudfront"></a> [cloudfront](#input_cloudfront)                      | The object defining settings for the CloudFront distribution | `any`                                                                                           | `null`  |    no    |
| <a name="input_cluster_name"></a> [cluster_name](#input_cluster_name)                | The name of the ECS cluster to run this service in           | `string`                                                                                        | n/a     |   yes    |
| <a name="input_dns"></a> [dns](#input_dns)                                           | Values from the dns module                                   | <pre>object({<br> default_ttl = number<br> zone_map = map(string)<br> })</pre>                  | n/a     |   yes    |
| <a name="input_log_group_name"></a> [log_group_name](#input_log_group_name)          | The name of the CloudWatch Logs log group to use             | `string`                                                                                        | n/a     |   yes    |
| <a name="input_name"></a> [name](#input_name)                                        | The name to give to this service                             | `string`                                                                                        | n/a     |   yes    |
| <a name="input_name_prefix"></a> [name_prefix](#input_name_prefix)                   | The prefix to prepend to resource names                      | `string`                                                                                        | n/a     |   yes    |
| <a name="input_port"></a> [port](#input_port)                                        | The port to run this service on                              | `number`                                                                                        | n/a     |   yes    |
| <a name="input_security_group_id"></a> [security_group_id](#input_security_group_id) | n/a                                                          | `string`                                                                                        | n/a     |   yes    |
| <a name="input_service"></a> [service](#input_service)                               | The object defining settings for the service component       | `any`                                                                                           | n/a     |   yes    |
| <a name="input_subnet_map"></a> [subnet_map](#input_subnet_map)                      | A map of the available subnets                               | <pre>map(list(object({<br> id = string<br> cidr = string<br> })))</pre>                         | n/a     |   yes    |
| <a name="input_task"></a> [task](#input_task)                                        | The object defining settings for the task component          | `any`                                                                                           | n/a     |   yes    |
| <a name="input_task_role_arn"></a> [task_role_arn](#input_task_role_arn)             | The IAM role for the task to assume                          | `string`                                                                                        | n/a     |   yes    |
| <a name="input_vpc_id"></a> [vpc_id](#input_vpc_id)                                  | n/a                                                          | `string`                                                                                        | n/a     |   yes    |

## Outputs

| Name                                                                    | Description |
| ----------------------------------------------------------------------- | ----------- |
| <a name="output_target_group"></a> [target_group](#output_target_group) | n/a         |

<!-- END_TF_DOCS -->
