
module "db" {
  source            = "./db"
  name_prefix       = local.qualified_name_prefix
  subnet_map        = module.network.subnets
  settings          = var.database
  security_group_id = aws_security_group.db_sg
}
