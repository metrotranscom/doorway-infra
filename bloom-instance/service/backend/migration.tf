
module "task" {
  source = "../../ecs/task"

  name_prefix = var.name_prefix
  # The migration job needs the same permissions as the main service
  task_role_arn = aws_iam_role.service.arn

  task = {
    name  = "${local.name}-migration"
    cpu   = var.migration.cpu
    ram   = var.migration.ram
    image = var.migration.image

    # The migration job requires the other env vars for startup, even if it doesn't use them
    env_vars = merge(
      local.env_vars,
      // But it also needs some extra vars for calling psql
      {
        PGHOST     = var.db.host
        PGPORT     = var.db.port
        PGDATABASE = var.db.db_name
        PGUSER     = var.db.username
      }
    )

    # It needs DATABASE_URL for seeding
    secrets = merge(
      local.secrets,
      # But it also needs the DB password for psql
      {
        PGPASSWORD = {
          arn = var.db.secret_arn
          key = "password"
        }
      }
    )
  }

  additional_tags = var.additional_tags
}
