resource "aws_s3_bucket" "user_upload_bucket" {
  bucket_prefix = "${var.resource_prefix}-user-uploads"
  tags          = local.default_tags_with_name
}
