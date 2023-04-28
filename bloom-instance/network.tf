module "network" {
  source = "./network"

  name_prefix   = local.default_name
  vpc_cidr      = var.network.vpc_cidr
  subnet_groups = var.network.subnet_groups
}
