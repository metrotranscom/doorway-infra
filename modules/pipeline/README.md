The pipeline module can be used to simplify the creation of dynamic pipelines via CodePipeline.

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
| <a name="module_notification_rules"></a> [notification\_rules](#module\_notification\_rules) | ./notification/rule/pipeline | n/a |
| <a name="module_notification_topic"></a> [notification\_topic](#module\_notification\_topic) | ./notification/topic | n/a |
| <a name="module_stages"></a> [stages](#module\_stages) | ./stage | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_codepipeline.pipeline](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/codepipeline) | resource |
| [aws_iam_policy.approvals](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.codebuild_artifacts](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.pipeline](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.pipeline](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.approvals](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.pipeline](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_s3_bucket.artifacts](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_build_env_vars"></a> [build\_env\_vars](#input\_build\_env\_vars) | Additional environmental variables to pass to every build action in this pipeline | `map(string)` | n/a | yes |
| <a name="input_build_policy_arns"></a> [build\_policy\_arns](#input\_build\_policy\_arns) | Additional policy ARNs to pass to every build action in this pipeline | `set(string)` | n/a | yes |
| <a name="input_codestar_connection_arn"></a> [codestar\_connection\_arn](#input\_codestar\_connection\_arn) | The ARN for the CodeStar Connection to use | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | The name of the pipeline | `string` | n/a | yes |
| <a name="input_name_prefix"></a> [name\_prefix](#input\_name\_prefix) | An identifier to prepend to resource names | `string` | n/a | yes |
| <a name="input_notification_rules"></a> [notification\_rules](#input\_notification\_rules) | Rules for triggering notifications on pipeline events | <pre>list(object({<br>    # Which topic to send notifications to <br>    topic  = string<br>    detail = optional(string, "BASIC")<br>    on     = map(set(string))<br>  }))</pre> | n/a | yes |
| <a name="input_notification_topics"></a> [notification\_topics](#input\_notification\_topics) | Named groups of people to notify when a certain event occurs | <pre>map(object({<br>    emails = set(string)<br>  }))</pre> | n/a | yes |
| <a name="input_sources"></a> [sources](#input\_sources) | The source locations for this pipeline to use | <pre>map(object({<br>    name       = string<br>    is_primary = optional(bool, false)<br>    repo = object({<br>      name   = string<br>      branch = string<br>    })<br>  }))</pre> | n/a | yes |
| <a name="input_stages"></a> [stages](#input\_stages) | The environments to deploy infra into | <pre>list(object({<br>    # The name of this environment<br>    name = string<br>    # An optional human-readable label to apply to the stage<br>    label = optional(string)<br><br>    # Additional policy ARNs to pass to every build action in this stage<br>    build_policy_arns = optional(set(string), [])<br>    # Additional env vars to pass to every build action in this stage<br>    build_env_vars = optional(map(string), {})<br><br>    default_network = optional(object({<br>      vpc_id          = string<br>      subnets         = set(string)<br>      security_groups = set(string)<br>      }), {<br>      vpc_id          = ""<br>      subnets         = []<br>      security_groups = []<br>    })<br><br>    # This must match the type definition in ./stage/inputs.tf<br>    actions = list(object({<br>      name  = string<br>      label = optional(string)<br>      type  = string<br>      order = number<br><br>      # Build vars<br>      compute_type = optional(string)<br>      image        = optional(string)<br>      timeout      = optional(number)<br>      policy_arns  = optional(set(string))<br>      env_vars     = optional(map(string))<br>      privileged   = optional(bool)<br>      secret_arns  = optional(map(string))<br><br>      vpc = optional(object({<br>        use             = optional(bool, false)<br>        vpc_id          = optional(string, "")<br>        subnets         = optional(set(string), [])<br>        security_groups = optional(set(string), [])<br>        }), {<br>        use             = false,<br>        vpc_id          = ""<br>        subnets         = []<br>        security_groups = []<br>      })<br><br>      buildspec = optional(string)<br><br>      # Approval vars<br>      topic = optional(string)<br>    }))<br>  }))</pre> | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_arn"></a> [arn](#output\_arn) | n/a |
| <a name="output_stages"></a> [stages](#output\_stages) | n/a |
<!-- END_TF_DOCS -->
