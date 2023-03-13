
module "public" {
  source = "./subnets"

  name            = "Public"
  name_prefix     = var.name_prefix
  vpc_id          = aws_vpc.vpc.id
  subnet_mappings = var.subnet_map.public
  additional_tags = var.additional_tags

  gateway_type = "igw"
  igw_id       = aws_internet_gateway.igw.id
}

# TODO: make sure of AZ/NGW alignment if more than one NGW
module "app" {
  source = "./subnets"

  name            = "App"
  name_prefix     = var.name_prefix
  vpc_id          = aws_vpc.vpc.id
  subnet_mappings = var.subnet_map.app
  additional_tags = var.additional_tags

  gateway_type = "ngw"
  ngw_id       = aws_nat_gateway.ngw[0].id
}

module "data" {
  source = "./subnets"

  name            = "Data"
  name_prefix     = var.name_prefix
  vpc_id          = aws_vpc.vpc.id
  subnet_mappings = var.subnet_map.data
  additional_tags = var.additional_tags
}
