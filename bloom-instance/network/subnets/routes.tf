
resource "aws_route_table" "route_table" {
  vpc_id = var.vpc_id

  tags = merge(
    {
      Name = var.name
    },
    local.tags,
  )
}

# Only set if var.ngw_id is not null
resource "aws_route" "ngw_route" {
  count                  = local.add_ngw ? 1 : 0
  route_table_id         = aws_route_table.route_table.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = var.ngw_id
}

# Only set if var.igw_id is not null
resource "aws_route" "igw_route" {
  count                  = local.add_igw ? 1 : 0
  route_table_id         = aws_route_table.route_table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = var.igw_id
}

resource "aws_route_table_association" "rt_assoc" {
  for_each       = aws_subnet.subnets
  subnet_id      = each.value.id
  route_table_id = aws_route_table.route_table.id
}
