
resource "aws_rds_cluster" "aurora" {
  count = local.is_serverless ? 1 : 0

  # Identification
  cluster_identifier_prefix = var.name_prefix
  database_name             = var.settings.db_name

  # Modification protection
  deletion_protection = var.settings.prevent_deletion
  apply_immediately   = var.settings.apply_changes_immediately

  # Engine
  engine         = "aurora-postgresql" # Intentionally hardcoded
  engine_version = var.settings.engine_version
  engine_mode    = "provisioned" # Intentionally hardcoded; required for serverless v2

  # Storage settings are not supported
  #db_cluster_instance_class = var.settings.instance_class
  #allocated_storage = local.min_storage
  #storage_type = "io1" # Intentionally hardcoded
  #storage_encrypted
  #kms_key_id

  # Scaling
  serverlessv2_scaling_configuration {
    min_capacity = var.settings.serverless_capacity.min
    max_capacity = var.settings.serverless_capacity.max
  }

  # Observability
  enabled_cloudwatch_logs_exports = ["postgresql"] # Intentionally hardcoded

  # Security
  iam_database_authentication_enabled = true # Intentionally hardcoded
  vpc_security_group_ids              = [aws_security_group.db.id]
  master_username                     = var.settings.username
  master_password                     = var.settings.password

  # Backups
  backup_retention_period   = var.settings.backups.retention
  preferred_backup_window   = var.settings.backups.window
  copy_tags_to_snapshot     = true # Intentionally hardcoded
  final_snapshot_identifier = var.name_prefix

  # Updates
  #preferred_maintenace_window

  # Config
  #db_cluster_parameter_group

  # Network
  port                 = var.settings.port
  network_type         = "IPV4" # Intentionally hardcoded
  db_subnet_group_name = aws_db_subnet_group.db.id

  # TLS


}

resource "aws_rds_cluster_instance" "serverless" {
  count = local.is_serverless ? 1 : 0

  identifier_prefix    = var.name_prefix
  cluster_identifier   = aws_rds_cluster.aurora[0].cluster_identifier
  instance_class       = "db.serverless"
  engine               = aws_rds_cluster.aurora[0].engine
  engine_version       = aws_rds_cluster.aurora[0].engine_version
  db_subnet_group_name = aws_db_subnet_group.db.id
}
