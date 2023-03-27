
resource "aws_db_instance" "db" {
  # Identification
  db_name           = var.db_name
  identifier_prefix = var.name_prefix

  # Engine
  engine         = "postgres" # Intentionally hardcoded
  engine_version = var.engine_version

  # Resources
  instance_class        = var.instance_class
  allocated_storage     = var.min_storage
  max_allocated_storage = var.max_storage
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
  backup_retention_period  = var.backup_retention
  backup_window            = var.backup_window
  copy_tags_to_snapshot    = true  # Intentionally hardcoded
  delete_automated_backups = false # Intentionally hardcoded


  # Updates
  #maintenance_window

  # Config
  #option_group_name
  #parameter_group_name

  # Network
  port                 = var.port
  network_type         = "IPV4" # Intentionally hardcoded
  db_subnet_group_name = var.db_subnet_group_id

  # TLS
  #ca_cert_identifier
  #kms_key_id

  deletion_protection = var.prevent_deletion
}
