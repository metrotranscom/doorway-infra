<!-- BEGIN_TF_DOCS -->

## Requirements

No requirements.

## Providers

| Name                                             | Version |
| ------------------------------------------------ | ------- |
| <a name="provider_aws"></a> [aws](#provider_aws) | n/a     |

## Modules

| Name                                                                                               | Source    | Version |
| -------------------------------------------------------------------------------------------------- | --------- | ------- |
| <a name="module_private_subnet_groups"></a> [private_subnet_groups](#module_private_subnet_groups) | ./subnets | n/a     |
| <a name="module_public_subnet_group"></a> [public_subnet_group](#module_public_subnet_group)       | ./subnets | n/a     |

## Resources

| Name                                                                                                                     | Type     |
| ------------------------------------------------------------------------------------------------------------------------ | -------- |
| [aws_eip.ngw_eip](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eip)                       | resource |
| [aws_internet_gateway.igw](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/internet_gateway) | resource |
| [aws_nat_gateway.ngw](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/nat_gateway)           | resource |
| [aws_vpc.vpc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc)                           | resource |

## Inputs

| Name                                                                           | Description                                       | Type                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        | Default         | Required |
| ------------------------------------------------------------------------------ | ------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | --------------- | :------: |
| <a name="input_additional_tags"></a> [additional_tags](#input_additional_tags) | Additional tags to apply to our network resources | `map(string)`                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               | `null`          |    no    |
| <a name="input_name"></a> [name](#input_name)                                  | The name to use for subnet resources              | `string`                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    | `"default"`     |    no    |
| <a name="input_name_prefix"></a> [name_prefix](#input_name_prefix)             | The prefix to prepend to resource names           | `string`                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    | n/a             |   yes    |
| <a name="input_subnet_groups"></a> [subnet_groups](#input_subnet_groups)       | The subnets to create in our VPC                  | <pre>map(<br> object({<br> # The name to give to subnets in this group<br> name = string<br><br> # Whether this subnet group is public<br> # Highlander rules: there can be only one<br> is_public = optional(bool, false)<br><br> # Whether this group of subnets needs an NGW<br> # Mutually exclusive with is_public<br> use_ngw = optional(bool, false)<br><br> # The AZ/CIDR mappings for each subnet in this group<br> subnets = list(<br> object({<br> az = string<br> cidr = string<br> })<br> )<br> })<br> )</pre> | n/a             |   yes    |
| <a name="input_vpc_cidr"></a> [vpc_cidr](#input_vpc_cidr)                      | The IP addresses to allocate to our VPC           | `string`                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    | `"10.0.0.0/16"` |    no    |

## Outputs

| Name                                                                          | Description                                                        |
| ----------------------------------------------------------------------------- | ------------------------------------------------------------------ |
| <a name="output_app_subnets"></a> [app_subnets](#output_app_subnets)          | n/a                                                                |
| <a name="output_public_subnets"></a> [public_subnets](#output_public_subnets) | a list of just the public subnets                                  |
| <a name="output_subnets"></a> [subnets](#output_subnets)                      | a map of all subnets indexed by subnet group id (including public) |
| <a name="output_vpc"></a> [vpc](#output_vpc)                                  | n/a                                                                |

<!-- END_TF_DOCS -->
