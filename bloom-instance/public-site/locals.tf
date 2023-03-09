
locals {
  port = var.service_definition.port != null ? var.service_definition.port : 3000
}
