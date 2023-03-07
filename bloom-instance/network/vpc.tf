
resource "aws_vpc" "vpc" {
  cidr_block = var.vpc_cidr
  tags       = local.tags_with_name
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id
  tags   = local.tags_with_name
}

# Skip NGW for now
/*
resource "aws_eip" "ngw_eip" {
  vpc  = true
  tags = local.tags_with_name
}

resource "aws_nat_gateway" "ngw" {
  allocation_id = aws_eip.ngw_eip.id

  subnet_id     = aws_subnet.public[0].id
  tags          = local.tags_with_name

  depends_on = [aws_internet_gateway.igw]
}
*/
