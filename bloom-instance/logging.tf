resource "aws_s3_bucket" "logging_bucket" {
  bucket_prefix = "${var.resource_prefix}-logging"
  tags          = local.default_tags_with_name
}

resource "aws_s3_bucket_acl" "logging_bucket_acl" {
  bucket = aws_s3_bucket.logging_bucket.id
  acl    = "private"
}
