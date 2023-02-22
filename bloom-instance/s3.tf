resource "aws_s3_bucket" "user_upload_bucket" {
  bucket_prefix = "${var.resource_prefix}-user-uploads"
  tags          = local.default_tags_with_name
}

resource "aws_s3_bucket_acl" "user_upload_bucket_acl" {
  bucket = aws_s3_bucket.user_upload_bucket.id
  acl    = "private"
}
