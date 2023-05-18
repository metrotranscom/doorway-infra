
locals {
  # A namespace for resources created in this module
  resource_namespace = "${var.name_prefix}-service-${var.service_definition.name}"

  # The port for this service to listen on
  port = var.service_definition.port != null ? var.service_definition.port : 3100
  name = var.service_definition.name

  base_task = var.service_definition.task
  service   = var.service_definition.service

  # Add service-specific env vars
  env_vars = merge(
    local.base_task.env_vars,
    tomap({
      # Core Bloom vars
      PORT                = local.port,
      PARTNERS_BASE_URL   = var.partners_portal_url
      PARTNERS_PORTAL_URL = var.partners_portal_url

      # Required to start the server, but not used
      EMAIL_API_KEY     = "SG.<dummy-value>"
      APP_SECRET        = "<dummy-value-that-is-at-least-16-character-long>"
      CLOUDINARY_SECRET = "<dummy-value>"
      CLOUDINARY_KEY    = "<dummy-value>"

      # Disable color in log output
      # Makes logs more readable in CloudWatch
      NO_COLOR = "true"
    })
  )

  secrets = {
    DATABASE_URL = {
      arn = var.db.secret_arn
      key = "uri"
    }
  }

  # Set modified env_vars on task object
  task = merge(
    local.base_task,
    {
      env_vars = local.env_vars
      secrets  = local.secrets
    }
  )
}
