
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

module "app" {
  source = "./subnets"

  name            = "App"
  name_prefix     = var.name_prefix
  vpc_id          = aws_vpc.vpc.id
  subnet_mappings = var.subnet_map.app
  additional_tags = var.additional_tags
}

module "data" {
  source = "./subnets"

  name            = "Data"
  name_prefix     = var.name_prefix
  vpc_id          = aws_vpc.vpc.id
  subnet_mappings = var.subnet_map.data
  additional_tags = var.additional_tags
}
