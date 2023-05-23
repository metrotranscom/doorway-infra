
locals {
  task_name   = "import-listings"
  name_prefix = "${var.name_prefix}-${local.task_name}-task"

  # Add DATABASE_URL to other env vars
  # env_vars = merge(
  #   var.settings.env_vars,
  #   {
  #     DATABASE_URL = var.db.connection_string
  #   }
  # )

  task = {
    name  = local.task_name
    image = var.settings.image

    # These are unlikely to change but can be moved to vars if needed
    cpu = 256
    ram = 512

    env_vars = var.settings.env_vars

    secrets = {
      DATABASE_URL = {
        arn = var.db.secret_arn
        key = "uri"
      }
    }
  }

  schedule = {
    description = "Import listings from external Bloom endpoint"
    enabled     = var.settings.enabled
    expression  = var.settings.schedule
  }

  network = {
    subnet_group    = var.settings.subnet_group
    security_groups = [aws_security_group.task.id]
  }
}

module "cronjob" {
  source = "../"

  name_prefix     = var.name_prefix
  ecs_cluster_arn = var.ecs_cluster_arn
  log_group_name  = var.log_group_name
  task_role_arn   = "" # Does not need access to any AWS resources
  subnet_groups   = var.network.subnets

  task     = local.task
  schedule = local.schedule
  network  = local.network
}

resource "aws_security_group" "task" {
  name        = local.name_prefix
  description = "Import Listings Task (${var.name_prefix})"
  vpc_id      = var.network.vpc.id
}

# Enable outbound connections to any HTTPS endpoint
# Need to hit external API endpoint and Secrets Manager
resource "aws_vpc_security_group_egress_rule" "allow_https" {
  security_group_id = aws_security_group.task.id

  description = "Allow full access to HTTPS from task ${local.task_name}"
  cidr_ipv4   = "0.0.0.0/0"
  from_port   = "443"
  to_port     = "443"
  ip_protocol = "tcp"
}

# Enable outbound connections to any HTTPS endpoint
# Just in case the backend endpoint is HTTP-only for some reason
resource "aws_vpc_security_group_egress_rule" "allow_http" {
  security_group_id = aws_security_group.task.id

  description = "Allow full access to HTTP from task ${local.task_name}"
  cidr_ipv4   = "0.0.0.0/0"
  from_port   = "80"
  to_port     = "80"
  ip_protocol = "tcp"
}

# Enable egress to database
resource "aws_vpc_security_group_egress_rule" "db" {
  security_group_id = aws_security_group.task.id

  description = "Allow ${local.task_name} task to access database"
  cidr_ipv4   = "0.0.0.0/0"
  from_port   = var.db.port
  to_port     = var.db.port
  ip_protocol = "tcp"
}

# Enable inbound connections to DB from task
resource "aws_vpc_security_group_ingress_rule" "import_listings_to_db" {
  security_group_id = var.db.security_group_id

  description = "Allow ${local.task_name} task to access database"
  from_port   = var.db.port
  to_port     = var.db.port
  ip_protocol = "tcp"

  referenced_security_group_id = aws_security_group.task.id
}
