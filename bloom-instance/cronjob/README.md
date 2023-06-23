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
| <a name="module_task"></a> [task](#module\_task) | ../ecs/task | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_iam_policy.run_task](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.scheduler_exec](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_scheduler_schedule.task](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/scheduler_schedule) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_additional_tags"></a> [additional\_tags](#input\_additional\_tags) | Additional tags to apply to task resources | `map(string)` | `null` | no |
| <a name="input_ecs_cluster_arn"></a> [ecs\_cluster\_arn](#input\_ecs\_cluster\_arn) | The ECS cluster to run this task in | `string` | n/a | yes |
| <a name="input_log_group_name"></a> [log\_group\_name](#input\_log\_group\_name) | The name of the CloudWatch Logs log group to use | `string` | n/a | yes |
| <a name="input_name_prefix"></a> [name\_prefix](#input\_name\_prefix) | The prefix to prepend to resource names | `string` | n/a | yes |
| <a name="input_network"></a> [network](#input\_network) | n/a | <pre>object({<br>    assign_public_ip = optional(bool, false)<br>    subnet_group     = string<br>    security_groups  = list(string)<br>  })</pre> | n/a | yes |
| <a name="input_schedule"></a> [schedule](#input\_schedule) | n/a | <pre>object({<br>    enabled = optional(bool, true)<br><br>    # https://docs.aws.amazon.com/AmazonCloudWatch/latest/events/ScheduledEvents.html<br>    expression = string<br>  })</pre> | n/a | yes |
| <a name="input_subnet_groups"></a> [subnet\_groups](#input\_subnet\_groups) | A map of the available subnets | <pre>map(list(object({<br>    id   = string<br>    cidr = string<br>  })))</pre> | n/a | yes |
| <a name="input_task"></a> [task](#input\_task) | The ECS task definition object | `any` | n/a | yes |
| <a name="input_task_role_arn"></a> [task\_role\_arn](#input\_task\_role\_arn) | The IAM role for the task to assume | `string` | n/a | yes |

## Outputs

No outputs.
<!-- END_TF_DOCS -->