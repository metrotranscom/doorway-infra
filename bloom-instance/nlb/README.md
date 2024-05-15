<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_listeners"></a> [listeners](#module\_listeners) | ./listener | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_lb.nlb](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_additional_tags"></a> [additional\_tags](#input\_additional\_tags) | Additional tags to apply to NLB resources | `map(string)` | `null` | no |
| <a name="input_alb_arn"></a> [alb\_arn](#input\_alb\_arn) | The API ALB | `string` | n/a | yes |
| <a name="input_certificate_arn"></a> [certificate\_arn](#input\_certificate\_arn) | ARN for the TLS cert | `string` | n/a | yes |
| <a name="input_enable_logging"></a> [enable\_logging](#input\_enable\_logging) | Whether to enable logging on this NLB | `bool` | `true` | no |
| <a name="input_internal"></a> [internal](#input\_internal) | Whether this NLB is public or internal | `bool` | `true` | no |
| <a name="input_listeners"></a> [listeners](#input\_listeners) | The listeners to create | <pre>map(object({<br>    allowed_ips     = optional(list(string))<br>    allowed_subnets = optional(list(string))<br><br>  }))</pre> | n/a | yes |
| <a name="input_log_bucket"></a> [log\_bucket](#input\_log\_bucket) | The S3 bucket to write NLB logs to | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | The name to give to give to this NLB and its related resources | `string` | n/a | yes |
| <a name="input_name_prefix"></a> [name\_prefix](#input\_name\_prefix) | The prefix to prepend to resource names | `string` | n/a | yes |
| <a name="input_security_group_id"></a> [security\_group\_id](#input\_security\_group\_id) | n/a | `string` | n/a | yes |
| <a name="input_subnet_group"></a> [subnet\_group](#input\_subnet\_group) | The identifier for the subnet group to place the NLB into | `string` | n/a | yes |
| <a name="input_subnets"></a> [subnets](#input\_subnets) | A map of the available subnets | <pre>map(list(object({<br>    id   = string<br>    cidr = string<br>  })))</pre> | n/a | yes |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | The ID of the VPC to create NLB resources in | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_arn"></a> [arn](#output\_arn) | n/a |
| <a name="output_dns_name"></a> [dns\_name](#output\_dns\_name) | n/a |
| <a name="output_listeners"></a> [listeners](#output\_listeners) | n/a |
| <a name="output_log_prefix"></a> [log\_prefix](#output\_log\_prefix) | Used for generating log bucket policy |
| <a name="output_nlb"></a> [nlb](#output\_nlb) | n/a |
| <a name="output_zone_id"></a> [zone\_id](#output\_zone\_id) | n/a |
<!-- END_TF_DOCS -->