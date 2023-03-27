
# Temporary; copied from base-service
data "aws_subnet" "first" {
  id = var.subnet_ids[0]
}

locals {
  name_prefix = var.name_prefix

  # Determine whether to use RDS or Aurora Serverless
  type          = var.settings.type
  is_rds        = local.type == "rds"
  is_aurora     = !local.is_rds
  is_serverless = local.type == "aurora-serverless"

  vpc_id     = data.aws_subnet.first.vpc_id
  subnet_ids = var.subnet_ids

  # Storage
  min_storage = var.settings.storage.min
  max_storage = var.settings.storage.max <= local.min_storage ? local.min_storage : var.settings.storage.max
}

resource "aws_db_subnet_group" "db" {
  name_prefix = local.name_prefix
  subnet_ids  = local.subnet_ids
}

resource "aws_security_group" "db" {
  name        = "${local.name_prefix}-db"
  description = "Enable access to ${local.name_prefix} database"
  vpc_id      = local.vpc_id
}

module "rds" {
  source = "./rds"
  count  = local.is_rds ? 1 : 0

  name_prefix = local.name_prefix

  # Generated resources
  security_group_id  = aws_security_group.db.id
  db_subnet_group_id = aws_db_subnet_group.db.id

  # From settings var
  db_name          = var.settings.db_name
  username         = var.settings.username
  engine_version   = var.settings.engine_version
  instance_class   = var.settings.instance_class
  port             = var.settings.port
  min_storage      = local.min_storage
  max_storage      = local.max_storage
  backup_retention = var.settings.backups.retention
  backup_window    = var.settings.backups.window
  prevent_deletion = var.settings.prevent_deletion
}
