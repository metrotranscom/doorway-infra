
locals {
  port          = var.service_definition.port != null ? var.service_definition.port : 3000
  bucket_prefix = "${var.name_prefix}/${var.service_definition.name}"
}
