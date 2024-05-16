<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 5.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | ~> 5.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_log_bucket"></a> [log\_bucket](#module\_log\_bucket) | ../s3 | n/a |
| <a name="module_policies"></a> [policies](#module\_policies) | ./policy | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_cloudfront_distribution.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfront_distribution) | resource |
| [aws_cloudfront_origin_request_policy.origin_request_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfront_origin_request_policy) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_alb_map"></a> [alb\_map](#input\_alb\_map) | The available ALBs | <pre>map(object({<br>    arn      = string<br>    dns_name = string<br>  }))</pre> | n/a | yes |
| <a name="input_cert_map"></a> [cert\_map](#input\_cert\_map) | ARNs for TLS certificates to apply to secure listeners | `map(string)` | n/a | yes |
| <a name="input_distribution"></a> [distribution](#input\_distribution) | The object defining settings for the service component | <pre>object({<br>    enabled     = optional(bool, true)<br>    price_class = optional(string, "PriceClass_100")<br><br>    certificate = object({<br>      arn = string<br>    })<br><br>    # Note: This module only supports ALB origins right now<br>    origin = object({<br>      alb = string<br>    })<br><br>    restrictions = object({<br>      geo = object({<br>        type      = string<br>        locations = optional(list(string), [])<br>      })<br>    })<br><br>    cache = map(object({<br>      viewer_protocol_policy = optional(string, "redirect-to-https")<br>      compress               = optional(bool, false)<br>      order                  = optional(number, 1)<br><br>      allowed_method_set = string<br>      cached_method_set  = string<br><br>      # Either policy_id or policy is required<br>      policy_id = optional(string)<br>      policy = optional(object({<br>        name    = string<br>        comment = string<br><br>        accept_brotli = optional(bool, false)<br>        accept_gzip   = optional(bool, false)<br><br>        ttl = object({<br>          min     = number<br>          max     = number<br>          default = number<br>        })<br><br>        cookies = object({<br>          include = string<br>          names   = optional(list(string))<br>        })<br><br>        headers = object({<br>          include = string<br>          names   = optional(list(string))<br>        })<br><br>        query = object({<br>          include = string<br>          names   = optional(list(string))<br>        })<br>      }))<br>    }))<br>  })</pre> | n/a | yes |
| <a name="input_domains"></a> [domains](#input\_domains) | n/a | `list(string)` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | The name to give to this CloudFront distribution | `string` | n/a | yes |
| <a name="input_name_prefix"></a> [name\_prefix](#input\_name\_prefix) | The prefix to prepend to resource names | `string` | n/a | yes |
| <a name="input_web_acl_id"></a> [web\_acl\_id](#input\_web\_acl\_id) | The ID of the Web Application Firewall Access Control List (ACL) | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_arn"></a> [arn](#output\_arn) | n/a |
| <a name="output_dns_name"></a> [dns\_name](#output\_dns\_name) | n/a |
| <a name="output_domains"></a> [domains](#output\_domains) | n/a |
| <a name="output_hosted_zone_id"></a> [hosted\_zone\_id](#output\_hosted\_zone\_id) | n/a |
<!-- END_TF_DOCS -->