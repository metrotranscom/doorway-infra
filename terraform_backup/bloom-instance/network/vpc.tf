
resource "aws_vpc" "vpc" {
  cidr_block           = var.vpc_cidr
  tags                 = local.tags_with_name
  enable_dns_hostnames = true
  enable_dns_support   = true
}

# mandatory since we require exactly one set of public subnets
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id
  tags   = local.tags_with_name
}

# only needed if at least one group needs an ngw
resource "aws_eip" "ngw_eip" {
  count = local.ngw_count
  vpc   = true
  tags  = local.tags_with_name
}

# only needed if at least one group needs an ngw
resource "aws_nat_gateway" "ngw" {
  count         = local.ngw_count
  allocation_id = aws_eip.ngw_eip[count.index].id

  # use the first subnet in the public subnet group
  subnet_id = module.public_subnet_group.subnets[count.index].id
  tags      = local.tags_with_name

  depends_on = [aws_internet_gateway.igw]
}
