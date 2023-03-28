
module "db" {
  source      = "./db"
  name_prefix = local.default_name
  subnet_map  = module.network.subnets
  settings    = var.database
}
