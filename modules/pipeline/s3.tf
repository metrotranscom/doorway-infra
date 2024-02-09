
module "s3_bucket" {
  source="../s3"
  prefix="${local.qualified_name}-art"
}