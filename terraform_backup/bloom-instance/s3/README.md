<!-- BEGIN_TF_DOCS -->

## Requirements

No requirements.

## Providers

| Name                                             | Version |
| ------------------------------------------------ | ------- |
| <a name="provider_aws"></a> [aws](#provider_aws) | n/a     |

## Modules

| Name                                         | Source                        | Version |
| -------------------------------------------- | ----------------------------- | ------- |
| <a name="module_kms"></a> [kms](#module_kms) | terraform-aws-modules/kms/aws | 2.2.0   |

## Resources

| Name                                                                                                                                                                                                   | Type        |
| ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ | ----------- |
| [aws_s3_bucket.s3_bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket)                                                                                       | resource    |
| [aws_s3_bucket_intelligent_tiering_configuration.it-for-entire-bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_intelligent_tiering_configuration)        | resource    |
| [aws_s3_bucket_policy.s3_bucket_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_policy)                                                                  | resource    |
| [aws_s3_bucket_public_access_block.pa_block](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_public_access_block)                                                | resource    |
| [aws_s3_bucket_server_side_encryption_configuration.default_s3_encryption](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_server_side_encryption_configuration) | resource    |
| [aws_iam_policy_document.bucket_policy_document](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document)                                                   | data source |

## Inputs

| Name                                                                                                                                             | Description                                                                                                   | Type     | Default     | Required |
| ------------------------------------------------------------------------------------------------------------------------------------------------ | ------------------------------------------------------------------------------------------------------------- | -------- | ----------- | :------: |
| <a name="input_block_public_acls"></a> [block_public_acls](#input_block_public_acls)                                                             | Whether Amazon S3 should ignore public ACLs for this bucket.                                                  | `bool`   | `true`      |    no    |
| <a name="input_block_public_policy"></a> [block_public_policy](#input_block_public_policy)                                                       | Whether Amazon S3 should block public bucket policies for this bucket.                                        | `bool`   | `true`      |    no    |
| <a name="input_force_destroy"></a> [force_destroy](#input_force_destroy)                                                                         | Delete bucket even if it has data in it.                                                                      | `bool`   | `true`      |    no    |
| <a name="input_ignore_public_acls"></a> [ignore_public_acls](#input_ignore_public_acls)                                                          | Whether Amazon S3 should ignore public ACLs for this bucket.                                                  | `bool`   | `true`      |    no    |
| <a name="input_intelligent_tiering_archive_days"></a> [intelligent_tiering_archive_days](#input_intelligent_tiering_archive_days)                | The ammount of days before a file goes into archive status. Defaults to 90                                    | `number` | `90`        |    no    |
| <a name="input_intelligent_tiering_deep_archive_days"></a> [intelligent_tiering_deep_archive_days](#input_intelligent_tiering_deep_archive_days) | The ammount of days before a file goes into deep archive status. Defaults to 180                              | `number` | `180`       |    no    |
| <a name="input_intelligent_tiering_status"></a> [intelligent_tiering_status](#input_intelligent_tiering_status)                                  | Whether or not intelligent tiering is enabled. If not you should put your own lifecycle policy on the bucket. | `string` | `"Enabled"` |    no    |
| <a name="input_name"></a> [name](#input_name)                                                                                                    | Part of the resource naming convention s/b [app]-[environment]-[stack]-[resource (i.e S3)]-[name i.e logs]    | `string` | n/a         |   yes    |
| <a name="input_restrict_public_buckets"></a> [restrict_public_buckets](#input_restrict_public_buckets)                                           | Whether Amazon S3 should restrict public bucket policies for this bucket.                                     | `bool`   | `true`      |    no    |

## Outputs

| Name                                                                                      | Description |
| ----------------------------------------------------------------------------------------- | ----------- |
| <a name="output_arn"></a> [arn](#output_arn)                                              | n/a         |
| <a name="output_bucket"></a> [bucket](#output_bucket)                                     | n/a         |
| <a name="output_encryption_key_arn"></a> [encryption_key_arn](#output_encryption_key_arn) | n/a         |

<!-- END_TF_DOCS -->
