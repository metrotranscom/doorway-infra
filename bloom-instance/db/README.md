<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |
| <a name="provider_random"></a> [random](#provider\_random) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_db_instance.rds](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_instance) | resource |
| [aws_db_subnet_group.db](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_subnet_group) | resource |
| [aws_iam_service_linked_role.rds](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_service_linked_role) | resource |
| [aws_rds_cluster.aurora](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/rds_cluster) | resource |
| [aws_rds_cluster_instance.serverless](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/rds_cluster_instance) | resource |
| [aws_secretsmanager_secret.conn_string](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret) | resource |
| [aws_secretsmanager_secret_version.conn_string](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret_version) | resource |
| [aws_security_group.db](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [random_password.password](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) | resource |
| [aws_iam_role.rds_service](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_role) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_name_prefix"></a> [name\_prefix](#input\_name\_prefix) | The prefix to prepend to resource names | `string` | n/a | yes |
| <a name="input_settings"></a> [settings](#input\_settings) | Database settings | <pre>object({<br>    db_name                   = string<br>    type                      = string<br>    subnet_group              = string<br>    engine_version            = string<br>    instance_class            = string<br>    port                      = optional(number, 5432) # Default to postgres port<br>    prevent_deletion          = optional(bool, true)   # We usually want to default to preserving the database<br>    apply_changes_immediately = optional(bool, false)<br>    username                  = string<br>    password                  = optional(string)<br><br>    maintenance_window = string<br><br>    # Only valid for type "rds"<br>    storage = optional(object({<br>      min = number<br>      max = optional(number, 0)<br>      #encrypt = optional(bool, false)<br>      }), {<br>      min = 20<br>      max = 0<br>    })<br><br>    backups = object({<br>      retention = number<br>      window    = string<br>    })<br><br>    # Only valid for type "aurora-serverless"<br>    serverless_capacity = optional(object({<br>      min = number<br>      max = number<br>    }))<br>  })</pre> | n/a | yes |
| <a name="input_subnet_map"></a> [subnet\_map](#input\_subnet\_map) | A map of the available subnets | <pre>map(list(object({<br>    id     = string<br>    vpc_id = string<br>  })))</pre> | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_connection_string"></a> [connection\_string](#output\_connection\_string) | n/a |
| <a name="output_db_name"></a> [db\_name](#output\_db\_name) | n/a |
| <a name="output_host"></a> [host](#output\_host) | n/a |
| <a name="output_port"></a> [port](#output\_port) | n/a |
| <a name="output_secret_arn"></a> [secret\_arn](#output\_secret\_arn) | n/a |
| <a name="output_security_group_id"></a> [security\_group\_id](#output\_security\_group\_id) | n/a |
| <a name="output_username"></a> [username](#output\_username) | n/a |
<!-- END_TF_DOCS -->