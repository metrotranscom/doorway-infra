
locals {
  # Using gateway_type rather than the presence of IDs prevents this issue in TF:
  # `The "count" value depends on resource attributes that cannot be determined until apply`
  add_ngw = var.gateway_type == "ngw" ? true : false
  add_igw = var.gateway_type == "igw" ? true : false
}
