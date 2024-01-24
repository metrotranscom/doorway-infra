<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |
| <a name="provider_aws.use1"></a> [aws.use1](#provider\_aws.use1) | n/a |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_zones"></a> [zones](#module\_zones) | ../dns/zone-resolver | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_acm_certificate.cert](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/acm_certificate) | resource |
| [aws_acm_certificate_validation.cert](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/acm_certificate_validation) | resource |
| [aws_route53_record.cert](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cert"></a> [cert](#input\_cert) | Information about the TLS certificate to create | <pre>object({<br>    domain        = string<br>    auto_validate = optional(bool, true)<br>    alt_names     = optional(list(string))<br>  })</pre> | n/a | yes |
| <a name="input_zones"></a> [zones](#input\_zones) | A map of zone names to IDs | `map(string)` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_arn"></a> [arn](#output\_arn) | n/a |
| <a name="output_unmatched_validation_records"></a> [unmatched\_validation\_records](#output\_unmatched\_validation\_records) | n/a |
<!-- END_TF_DOCS -->