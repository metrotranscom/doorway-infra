
locals {
  # A namespace for resources created in this module
  resource_namespace = "${var.name_prefix}-service-${var.service_definition.name}"

  # The port for this service to listen on
  port = var.service_definition.port != null ? var.service_definition.port : 3000
  name = var.service_definition.name

  base_task = var.service_definition.task
  service   = var.service_definition.service

  # Add service-specific env vars
  env_vars = merge(
    local.base_task.env_vars,
    tomap({
      # Core Bloom vars
      NEXTJS_PORT      = local.port,
      BACKEND_API_BASE = var.backend_api_base
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
