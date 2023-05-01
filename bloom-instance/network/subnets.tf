
# the public group has to be created separately to avoid circular dependencies
# subnets->ngw->igw->subnets
module "public_subnet_group" {
  source = "./subnets"

  name_prefix     = var.name_prefix
  vpc_id          = aws_vpc.vpc.id
  additional_tags = var.additional_tags

  name            = local.public_subnet_group.name
  subnet_mappings = local.public_subnet_group.subnets

  gateway_type = "igw"
  igw_id       = aws_internet_gateway.igw.id
}

module "private_subnet_groups" {
  source = "./subnets"

  for_each = { for id, group in local.private_subnet_groups : id => group }

  name_prefix     = var.name_prefix
  vpc_id          = aws_vpc.vpc.id
  additional_tags = var.additional_tags

  name            = each.value.name
  subnet_mappings = each.value.subnets

  gateway_type = each.value.use_ngw ? "ngw" : "none"
  ngw_id       = each.value.use_ngw ? aws_nat_gateway.ngw[0].id : null
}
