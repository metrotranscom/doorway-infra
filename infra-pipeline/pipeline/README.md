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
| <a name="module_apply"></a> [apply](#module\_apply) | ./codebuild | n/a |
| <a name="module_notification_rules"></a> [notification\_rules](#module\_notification\_rules) | ./notification/rule/pipeline | n/a |
| <a name="module_notification_topic"></a> [notification\_topic](#module\_notification\_topic) | ./notification/topic | n/a |
| <a name="module_plan"></a> [plan](#module\_plan) | ./codebuild | n/a |

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
| <a name="input_codestar_connection_arn"></a> [codestar\_connection\_arn](#input\_codestar\_connection\_arn) | The ARN for the CodeStar Connection to use | `string` | n/a | yes |
| <a name="input_environments"></a> [environments](#input\_environments) | The environments to deploy infra into | <pre>list(object({<br>    # The name of this environment<br>    name = string<br><br>    # Which terraform workspace to use<br>    workspace = string<br><br>    # CodeBuild values for the plan action<br>    plan = object({<br>      # The location of the tvfars file<br>      var_file = object({<br>        # Source name<br>        source = string<br>        # Path<br>        path = string<br>      })<br><br>      # ARNs of IAM policies to attach to the CodeBuild role<br>      policy_arns = list(string)<br><br>      # Environment variables to pass to the build project<br>      env_vars = map(string)<br>    })<br><br>    # CodeBuild values for the apply action<br>    apply = object({<br>      # ARNs of IAM policies to attach to the CodeBuild role<br>      policy_arns = list(string)<br><br>      # Environment variables to pass to the build project<br>      env_vars = map(string)<br>    })<br><br>    # Whether this stage requires approval prior to deployment<br>    approval = optional(object({<br>      required = optional(bool, true)<br>      topic    = string<br>      }), {<br>      required = false<br>      topic    = ""<br>    })<br>  }))</pre> | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | The name of the pipeline | `string` | n/a | yes |
| <a name="input_name_prefix"></a> [name\_prefix](#input\_name\_prefix) | An identifier to prepend to resource names | `string` | n/a | yes |
| <a name="input_notification_rules"></a> [notification\_rules](#input\_notification\_rules) | Rules for triggering notifications on pipeline events | <pre>list(object({<br>    # Which topic to send notifications to <br>    topic  = string<br>    detail = optional(string, "BASIC")<br>    on     = map(set(string))<br>  }))</pre> | n/a | yes |
| <a name="input_notification_topics"></a> [notification\_topics](#input\_notification\_topics) | Named groups of people to notify when a certain event occurs | <pre>map(object({<br>    emails = set(string)<br>  }))</pre> | n/a | yes |
| <a name="input_sources"></a> [sources](#input\_sources) | The source locations for this pipeline to use | <pre>map(object({<br>    name       = string<br>    is_primary = optional(bool, false)<br>    repo = object({<br>      name   = string<br>      branch = string<br>    })<br>  }))</pre> | n/a | yes |
| <a name="input_tf_root"></a> [tf\_root](#input\_tf\_root) | The location (source repo and path) to run terraform commands | <pre>object({<br>    source = string<br>    path   = string<br>  })</pre> | n/a | yes |

## Outputs

No outputs.
<!-- END_TF_DOCS -->