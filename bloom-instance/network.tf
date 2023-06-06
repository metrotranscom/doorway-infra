module "network" {
  source = "./network"

  name_prefix   = local.qualified_name_prefix
  vpc_cidr      = var.network.vpc_cidr
  subnet_groups = var.network.subnet_groups
}
