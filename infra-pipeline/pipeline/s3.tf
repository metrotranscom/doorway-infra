
resource "aws_s3_bucket" "artifacts" {
  bucket        = var.name_prefix
  force_destroy = true
}
