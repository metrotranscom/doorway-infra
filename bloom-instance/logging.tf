resource "aws_s3_bucket" "logging_bucket" {
  bucket_prefix = "${var.resource_prefix}-logging"
}
