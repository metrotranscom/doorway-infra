<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 4.64 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 4.64.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_ecr_repos"></a> [ecr\_repos](#module\_ecr\_repos) | ./ecr_repo | n/a |
| <a name="module_pipeline"></a> [pipeline](#module\_pipeline) | ../modules/pipeline | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_codestarconnections_connection.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/codestarconnections_connection) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_application_name"></a> [application\_name](#input\_application\_name) | The name for the application deployed | `string` | n/a | yes |
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | The region to use when deploying regional resources | `string` | n/a | yes |
| <a name="input_ecr"></a> [ecr](#input\_ecr) | Information about available ECR repos, used for passing repo info to actions | <pre>object({<br>    default_region  = optional(string)<br>    default_account = optional(string)<br><br>    repo_groups = map(object({<br>      region    = optional(string)<br>      account   = optional(string)<br>      namespace = string<br>      repos     = set(string)<br>    }))<br>  })</pre> | n/a | yes |
| <a name="input_gh_codestar_conn_name"></a> [gh\_codestar\_conn\_name](#input\_gh\_codestar\_conn\_name) | The github/AWS Codestar connection resource for the repo. This allows AWS to connect to the github repo | `string` | n/a | yes |
| <a name="input_owner"></a> [owner](#input\_owner) | The owner of the resources created via these templates | `string` | n/a | yes |
| <a name="input_pipeline"></a> [pipeline](#input\_pipeline) | Settings for the pipeline | <pre>object({<br>    name = string<br>    # See ../modules/pipeline/inputs.tf for object structures<br>    sources = any<br><br>    # From ../modules/pipeline/inputs.tf<br>    # Necessary to avoid typing issues with "any" and lists<br>    stages = set(object({<br>      # The name of this environment<br>      name = string<br>      # An optional human-readable label to apply to the stage<br>      label = optional(string)<br><br>      # Additional policy ARNs to pass to every build action in this stage<br>      build_policy_arns = optional(set(string), [])<br>      # Additional env vars to pass to every build action in this stage<br>      build_env_vars = optional(map(string), {})<br><br>      default_network = optional(object({<br>        vpc_id          = string<br>        subnets         = set(string)<br>        security_groups = set(string)<br>        }), {<br>        vpc_id          = ""<br>        subnets         = []<br>        security_groups = []<br>      })<br><br>      # This is the same as in ../modules/pipeline/inputs.tf with exceptions noted<br>      actions = list(object({<br>        # These are new<br>        ecr_repo_access = optional(map(list(string)), {})<br><br>        # These are from the module<br>        name  = string<br>        label = optional(string)<br>        type  = string<br>        order = number<br><br>        compute_type = optional(string)<br>        image        = optional(string)<br>        timeout      = optional(number)<br>        policy_arns  = optional(set(string), [])<br>        env_vars     = optional(map(string), {})<br>        privileged   = optional(bool)<br>        secret_arns  = optional(map(string), {})<br><br>        vpc = optional(object({<br>          use             = optional(bool, false)<br>          vpc_id          = optional(string, "")<br>          subnets         = optional(set(string), [])<br>          security_groups = optional(set(string), [])<br>          }), {<br>          use             = false,<br>          vpc_id          = ""<br>          subnets         = []<br>          security_groups = []<br>        })<br><br>        buildspec = optional(string)<br><br>        # Approval vars<br>        topic = optional(string)<br>      }))<br>    }))<br><br>    notification_topics = any<br>    notify              = any<br>    build_policy_arns   = optional(set(string), [])<br>    build_env_vars      = optional(map(string), {})<br>  })</pre> | n/a | yes |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | A unique, immutable identifier for this project | `string` | n/a | yes |
| <a name="input_project_name"></a> [project\_name](#input\_project\_name) | A human-readable name for this project. Can be changed if needed | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_ecr_repos"></a> [ecr\_repos](#output\_ecr\_repos) | n/a |
| <a name="output_pipeline"></a> [pipeline](#output\_pipeline) | n/a |
<!-- END_TF_DOCS -->