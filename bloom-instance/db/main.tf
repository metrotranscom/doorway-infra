
locals {
  name_prefix = var.name_prefix

  # Determine whether to use RDS or Aurora Serverless
  type          = var.settings.type
  is_rds        = local.type == "rds"
  is_serverless = local.type == "aurora-serverless"

  # Network
  subnets    = var.subnet_map[var.settings.subnet_group]
  vpc_id     = local.subnets[0].vpc_id
  subnet_ids = [for subnet in local.subnets : subnet.id]

  # Storage
  min_storage = var.settings.storage.min
  max_storage = var.settings.storage.max <= local.min_storage ? local.min_storage : var.settings.storage.max

  # Password
  generate_password = var.settings.password == null
  pass_len          = 16 # The length of the generated password
  password          = local.generate_password ? random_password.password[0].result : var.settings.password

  # Placeholder for info about the database that's being created
  db = local.is_rds ? {
    host     = aws_db_instance.rds[0].address
    port     = aws_db_instance.rds[0].port
    username = aws_db_instance.rds[0].username
    db_name  = aws_db_instance.rds[0].db_name
    } : {
    host     = aws_rds_cluster.aurora[0].endpoint
    port     = aws_rds_cluster.aurora[0].port
    username = aws_rds_cluster.aurora[0].master_username
    db_name  = aws_rds_cluster.aurora[0].database_name
  }

  conn_string = "postgres://${local.db.username}:${local.password}@${local.db.host}:${local.db.port}/${local.db.db_name}"
}

resource "aws_db_subnet_group" "db" {
  name_prefix = local.name_prefix
  subnet_ids  = local.subnet_ids

  depends_on = [aws_iam_service_linked_role.rds]
}

resource "aws_security_group" "db" {
  name        = "${local.name_prefix}-db"
  description = "Enable access to ${local.name_prefix} database"
  vpc_id      = local.vpc_id
}
