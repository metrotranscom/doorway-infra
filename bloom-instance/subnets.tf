# Backend subnets
resource "aws_subnet" "backend" {
  for_each = { for idx, subnet in var.subnet_map.backend : idx => subnet }

  vpc_id            = aws_vpc.vpc.id
  availability_zone = each.value.az
  cidr_block        = each.value.cidr

  tags = merge(
    {
      Name = "${local.default_name}:backend_subnet-${each.key}"
    },
    local.default_tags
  )
}

# Data subnets
resource "aws_subnet" "data" {
  for_each = { for idx, subnet in var.subnet_map.data : idx => subnet }

  vpc_id            = aws_vpc.vpc.id
  availability_zone = each.value.az
  cidr_block        = each.value.cidr

  tags = merge(
    {
      Name = "${local.default_name}:data_subnet-${each.key}"
    },
    local.default_tags
  )
}

resource "aws_subnet" "data" {
  for_each = { for idx, subnet in var.subnet_map.data : idx => subnet }

  vpc_id            = aws_vpc.vpc.id
  availability_zone = each.value.az
  cidr_block        = each.value.cidr

  tags = merge(
    {
      Name = "${local.default_name}:data_subnet-${each.key}"
    },
    local.default_tags
  )
}