
resource "aws_db_instance" "rds" {
  count = local.is_rds ? 1 : 0

  # Identification
  db_name           = var.settings.db_name
  identifier_prefix = var.name_prefix

  # username         = var.settings.username


  # Engine
  engine         = "postgres" # Intentionally hardcoded
  engine_version = var.settings.engine_version

  # Resources
  instance_class        = var.settings.instance_class
  allocated_storage     = local.min_storage
  max_allocated_storage = local.max_storage
  storage_type          = "gp3" # Intentionally hardcoded
  #storage_encrypted

  # Observability
  enabled_cloudwatch_logs_exports = ["postgresql", "upgrade"] # Intentionally hardcoded
  #performance_insights_enabled

  # Security
  iam_database_authentication_enabled = true # Intentionally hardcoded
  #username
  #password
  #vpc_security_group_ids

  # Backup
  backup_retention_period  = var.settings.backups.retention
  backup_window            = var.settings.backups.window
  copy_tags_to_snapshot    = true  # Intentionally hardcoded
  delete_automated_backups = false # Intentionally hardcoded


  # Updates
  #maintenance_window

  # Config
  #option_group_name
  #parameter_group_name

  # Network
  port                 = var.settings.port
  network_type         = "IPV4" # Intentionally hardcoded
  db_subnet_group_name = aws_db_subnet_group.db.id

  # TLS
  #ca_cert_identifier
  #kms_key_id

  deletion_protection = var.settings.prevent_deletion
}
