# Public subnets
resource "aws_subnet" "public" {
  for_each = { for idx, subnet in var.subnet_map.public : idx => subnet }

  vpc_id            = aws_vpc.vpc.id
  availability_zone = each.value.az
  cidr_block        = each.value.cidr

  tags = merge(
    {
      Name = "${local.default_name}:public_subnet-${each.key}"
    },
    local.default_tags,
  )
}

# Route table for the public subnets
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.vpc.id

  # Local routes to VPC IPs are implicit, so we don't have to add those

  # This routes all unmatched traffic out to the internet over the IGW
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = merge(
    {
      Name = "${local.default_name}:backend_subnet_route_table"
    },
    local.default_tags
  )
}

# Association of the public subnet route table
resource "aws_route_table_association" "pub_rt_assoc" {
  for_each       = aws_subnet.public
  subnet_id      = each.value.id
  route_table_id = aws_route_table.public_route_table.id
}

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
