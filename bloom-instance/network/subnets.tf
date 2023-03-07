
module "public" {
  source = "./subnets"

  name            = "${var.name_prefix}:Public"
  vpc_id          = aws_vpc.vpc.id
  subnet_mappings = var.subnet_map.public
  tags            = var.tags

  gateway_type = "igw"
  igw_id       = aws_internet_gateway.igw.id
}

module "app" {
  source = "./subnets"

  name            = "${var.name_prefix}:App"
  vpc_id          = aws_vpc.vpc.id
  subnet_mappings = var.subnet_map.app
  tags            = var.tags
}

module "data" {
  source = "./subnets"

  name            = "${var.name_prefix}:Data"
  vpc_id          = aws_vpc.vpc.id
  subnet_mappings = var.subnet_map.data
  tags            = var.tags
}
