
resource "aws_s3_bucket" "bucket" {
  bucket_prefix = "${var.name_prefix}-${var.name}"
}

resource "aws_s3_bucket_public_access_block" "bucket" {
  bucket = aws_s3_bucket.bucket.id

  block_public_acls       = !var.is_public
  block_public_policy     = !var.is_public
  ignore_public_acls      = !var.is_public
  restrict_public_buckets = !var.is_public
}

resource "aws_s3_bucket_policy" "bucket" {
  bucket = aws_s3_bucket.bucket.id
  #policy = data.aws_iam_policy_document.allow_access_from_another_account.json
}
