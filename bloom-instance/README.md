
<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 4.57.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 4.57.1 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_albs"></a> [albs](#module\_albs) | ./alb | n/a |
| <a name="module_backend_api"></a> [backend\_api](#module\_backend\_api) | ./service/backend | n/a |
| <a name="module_certs"></a> [certs](#module\_certs) | ./cert | n/a |
| <a name="module_db"></a> [db](#module\_db) | ./db | n/a |
| <a name="module_dns"></a> [dns](#module\_dns) | ./dns | n/a |
| <a name="module_import_listings"></a> [import\_listings](#module\_import\_listings) | ./cronjob/import-listings | n/a |
| <a name="module_network"></a> [network](#module\_network) | ./network | n/a |
| <a name="module_partner_site"></a> [partner\_site](#module\_partner\_site) | ./service/partner-site | n/a |
| <a name="module_public_sites"></a> [public\_sites](#module\_public\_sites) | ./service/public-site | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_ecs_cluster.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_cluster) | resource |
| [aws_s3_bucket.logging_bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket.public_uploads](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket.secure_uploads](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket.static_content](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket_policy.log_bucket_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_policy) | resource |
| [aws_s3_bucket_policy.public_uploads](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_policy) | resource |
| [aws_s3_bucket_public_access_block.public_uploads](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_public_access_block) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_elb_service_account.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/elb_service_account) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_albs"></a> [albs](#input\_albs) | Settings for managing ALBs | <pre>map(object({<br>    # See alb/inputs.tf for more info<br>    subnet_group   = string<br>    enable_logging = optional(bool, true)<br>    internal       = optional(bool)<br><br>    # See alb/listeners/inputs.tf for more info<br>    listeners = map(object({<br>      port           = number<br>      default_action = optional(string, "404")<br><br>      allowed_ips     = optional(list(string))<br>      allowed_subnets = optional(list(string))<br><br>      tls = optional(object({<br>        enable           = optional(bool, true)<br>        default_cert     = string<br>        additional_certs = optional(list(string))<br>        }), {<br>        enable           = false<br>        default_cert     = null<br>        additional_certs = []<br>      })<br>    }))<br>  }))</pre> | n/a | yes |
| <a name="input_application_name"></a> [application\_name](#input\_application\_name) | The name for the application deployed | `string` | n/a | yes |
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | The region to use when deploying regional resources | `string` | n/a | yes |
| <a name="input_backend_api"></a> [backend\_api](#input\_backend\_api) | A service definition for the backend API | `any` | n/a | yes |
| <a name="input_certs"></a> [certs](#input\_certs) | The certificates to use | <pre>map(object({<br>    domain        = string<br>    auto_validate = optional(bool)<br>    alt_names     = optional(list(string))<br>  }))</pre> | n/a | yes |
| <a name="input_database"></a> [database](#input\_database) | Database settings | `any` | n/a | yes |
| <a name="input_dns"></a> [dns](#input\_dns) | Settings for managing DNS zones and records | `any` | n/a | yes |
| <a name="input_environment"></a> [environment](#input\_environment) | The stage of the software development lifecycle this deployement represents | `string` | `"dev"` | no |
| <a name="input_listings_import_task"></a> [listings\_import\_task](#input\_listings\_import\_task) | Setting for the "Import Listings" scheduled task | `any` | n/a | yes |
| <a name="input_network"></a> [network](#input\_network) | n/a | <pre>object({<br>    vpc_cidr = string<br><br>    # See ./network/inputs.tf for object structure<br>    subnet_groups = any<br>  })</pre> | n/a | yes |
| <a name="input_owner"></a> [owner](#input\_owner) | The owner of the resources created via these templates | `string` | n/a | yes |
| <a name="input_partner_site"></a> [partner\_site](#input\_partner\_site) | A service definition for the partner site | `any` | n/a | yes |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | A unique, immutable identifier for this project | `string` | n/a | yes |
| <a name="input_project_name"></a> [project\_name](#input\_project\_name) | A human-readable name for this project. Can be changed if needed | `string` | n/a | yes |
| <a name="input_public_sites"></a> [public\_sites](#input\_public\_sites) | A list of public portal service definitions | `any` | n/a | yes |
| <a name="input_s3_force_destroy"></a> [s3\_force\_destroy](#input\_s3\_force\_destroy) | n/a | `bool` | `false` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_cert_validation_records_not_created"></a> [cert\_validation\_records\_not\_created](#output\_cert\_validation\_records\_not\_created) | n/a |
| <a name="output_default_cluster_arn"></a> [default\_cluster\_arn](#output\_default\_cluster\_arn) | n/a |
| <a name="output_default_cluster_name"></a> [default\_cluster\_name](#output\_default\_cluster\_name) | n/a |
| <a name="output_network"></a> [network](#output\_network) | n/a |
| <a name="output_urls"></a> [urls](#output\_urls) | n/a |
<!-- END_TF_DOCS -->
