resource "aws_s3_bucket" "user_upload_bucket" {
  bucket_prefix = "${var.name_prefix}-user-uploads"
}