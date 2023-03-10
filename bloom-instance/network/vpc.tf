
resource "aws_vpc" "vpc" {
  cidr_block = var.vpc_cidr
  tags       = local.tags_with_name
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id
  tags   = local.tags_with_name
}

resource "aws_eip" "ngw_eip" {
  count = local.ngw_count
  vpc   = true
  tags  = local.tags_with_name
}

resource "aws_nat_gateway" "ngw" {
  count         = local.ngw_count
  allocation_id = aws_eip.ngw_eip[count.index].id

  subnet_id = module.public.subnets[count.index].id
  tags      = local.tags_with_name

  depends_on = [aws_internet_gateway.igw]
}
