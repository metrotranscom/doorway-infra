
resource "aws_s3_bucket" "artifacts" {
  # bucket_prefix is limited to 37 chars, so we have to keep this brief
  bucket_prefix = "${local.qualified_name}-art"
  force_destroy = true
}
