<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_route53_record.records](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_dns"></a> [dns](#input\_dns) | Config for managing DNS resources | <pre>object({<br>    # The TTL to use for all records when not specified (default 60 seconds)<br>    default_ttl = optional(number, 60)<br><br>    zones = map(object({<br>      # The zone ID for this hosted zone<br>      id = string<br><br>      # Records that should be added to this zone beyond what are created automatically<br>      additional_records = optional(list(object({<br>        # The DNS name for the record, ie google.com<br>        name = string<br><br>        # The type of record to create (CNAME, A, TXT, etc)<br>        type = string<br><br>        # The values for that record<br>        values = list(string)<br><br>        # The TTL for that record (defaults to default_ttl)<br>        ttl = optional(number)<br>      })))<br>    }))<br>  })</pre> | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_default_ttl"></a> [default\_ttl](#output\_default\_ttl) | n/a |
| <a name="output_zone_map"></a> [zone\_map](#output\_zone\_map) | n/a |
<!-- END_TF_DOCS -->