<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

No providers.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_alb_aliases"></a> [alb\_aliases](#module\_alb\_aliases) | ../dns/alias | n/a |
| <a name="module_cloudfront"></a> [cloudfront](#module\_cloudfront) | ../cloudfront | n/a |
| <a name="module_cloudfront_aliases"></a> [cloudfront\_aliases](#module\_cloudfront\_aliases) | ../dns/alias | n/a |
| <a name="module_service"></a> [service](#module\_service) | ../ecs/service | n/a |
| <a name="module_task"></a> [task](#module\_task) | ../ecs/task | n/a |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_additional_tags"></a> [additional\_tags](#input\_additional\_tags) | Additional tags to apply to service resources | `map(string)` | `null` | no |
| <a name="input_alb_map"></a> [alb\_map](#input\_alb\_map) | The available ALBs | <pre>map(object({<br>    arn      = string<br>    dns_name = string<br>    zone_id  = string<br>    security_group = object({<br>      id = string<br>    })<br>    listeners = map(object({<br>      arn       = string<br>      port      = number<br>      is_secure = bool<br>    }))<br>  }))</pre> | n/a | yes |
| <a name="input_cert_map"></a> [cert\_map](#input\_cert\_map) | ARNs for TLS certificates to apply to secure listeners | `map(string)` | n/a | yes |
| <a name="input_cloudfront"></a> [cloudfront](#input\_cloudfront) | The object defining settings for the CloudFront distribution | `any` | `null` | no |
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | The name of the ECS cluster to run this service in | `string` | n/a | yes |
| <a name="input_dns"></a> [dns](#input\_dns) | Values from the dns module | <pre>object({<br>    default_ttl = number<br>    zone_map    = map(string)<br>  })</pre> | n/a | yes |
| <a name="input_log_group_name"></a> [log\_group\_name](#input\_log\_group\_name) | The name of the CloudWatch Logs log group to use | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | The name to give to this service | `string` | n/a | yes |
| <a name="input_name_prefix"></a> [name\_prefix](#input\_name\_prefix) | The prefix to prepend to resource names | `string` | n/a | yes |
| <a name="input_port"></a> [port](#input\_port) | The port to run this service on | `number` | n/a | yes |
| <a name="input_service"></a> [service](#input\_service) | The object defining settings for the service component | `any` | n/a | yes |
| <a name="input_subnet_map"></a> [subnet\_map](#input\_subnet\_map) | A map of the available subnets | <pre>map(list(object({<br>    id   = string<br>    cidr = string<br>  })))</pre> | n/a | yes |
| <a name="input_task"></a> [task](#input\_task) | The object defining settings for the task component | `any` | n/a | yes |
| <a name="input_task_role_arn"></a> [task\_role\_arn](#input\_task\_role\_arn) | The IAM role for the task to assume | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_cloudfront_distribution"></a> [cloudfront\_distribution](#output\_cloudfront\_distribution) | n/a |
| <a name="output_security_group"></a> [security\_group](#output\_security\_group) | n/a |
| <a name="output_target_group"></a> [target\_group](#output\_target\_group) | n/a |
| <a name="output_url_list"></a> [url\_list](#output\_url\_list) | n/a |
| <a name="output_urls_by_listener"></a> [urls\_by\_listener](#output\_urls\_by\_listener) | n/a |
<!-- END_TF_DOCS -->