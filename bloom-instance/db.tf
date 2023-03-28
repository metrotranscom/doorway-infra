
module "db" {
  source      = "./database"
  name_prefix = local.default_name
  subnet_ids  = [for subnet in module.network.subnets.data : subnet.id]
  settings    = var.database
}
