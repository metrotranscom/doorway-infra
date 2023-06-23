The setup project creates the base infrastructure on which everything else gets deployed. Run it once for each environment being created.

<!-- Do not edit below this line! -->
<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 4.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 4.55.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_repos"></a> [repos](#module\_repos) | ./ecr | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | The AWS region to use when deploying regional resources | `string` | n/a | yes |
| <a name="input_environment"></a> [environment](#input\_environment) | The name of the environment | `string` | `"default"` | no |
| <a name="input_owner"></a> [owner](#input\_owner) | The owner of the resources created via these templates | `string` | n/a | yes |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | A project-specific identifier prepended to resource names | `string` | n/a | yes |
| <a name="input_project_name"></a> [project\_name](#input\_project\_name) | Name of the project | `string` | n/a | yes |
| <a name="input_repos"></a> [repos](#input\_repos) | A map of objects containing information for creating ECR repos | <pre>map(object({<br>    scan_images    = bool<br>    source_account = optional(string)<br>  }))</pre> | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_repos"></a> [repos](#output\_repos) | n/a |
<!-- END_TF_DOCS -->
