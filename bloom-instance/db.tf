
module "db" {
  source      = "./db"
  name_prefix = local.qualified_name_prefix
  subnet_map  = module.network.subnets
  settings    = var.database
}
