
resource "aws_subnet" "subnets" {
  for_each = { for idx, subnet in var.subnet_mappings : idx => subnet }

  vpc_id = var.vpc_id

  availability_zone = each.value.az
  cidr_block        = each.value.cidr

  tags = merge(
    {
      Name = "${var.name_prefix}:${var.name} ${each.key}"
    },
    var.additional_tags,
  )
}
