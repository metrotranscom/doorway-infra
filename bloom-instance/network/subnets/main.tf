
//data "aws_default_tags" "current" {}

locals {
  add_ngw = var.gateway_type == "ngw" ? true : false
  add_igw = var.gateway_type == "igw" ? true : false
  //tags    = var.tags != null ? var.tags : data.aws_default_tags.current.tags
}
