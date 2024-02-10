module "s3-artifacts" {
  source = "../../modules/s3"
  prefix = var.name_prefix
}
