
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

      # Temporary until support for secrets is added
      DATABASE_URL = var.db.connection_string

      # Temporary for fetching from Bloom backend
      BLOOM_API_BASE       = "https://hba-dev-proxy.herokuapp.com"
      BLOOM_LISTINGS_QUERY = "/listings"

      # Temporary
      EMAIL_API_KEY     = "SG.<dummy-value>"
      APP_SECRET        = "<dummy-value-that-is-at-least-16-character-long>"
      CLOUDINARY_SECRET = "<dummy-value>"
      CLOUDINARY_KEY    = "<dummy-value>"

      # For running migration tasks
      PGHOST     = var.db.host
      PGPORT     = var.db.port
      PGDATABASE = var.db.db_name
      PGUSER     = var.db.username
      PGPASSWORD = var.db.password
    })
  )

  # Set modified env_vars on task object
  task = merge(
    local.base_task,
    {
      env_vars = local.env_vars
    }
  )
}
