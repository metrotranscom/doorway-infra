resource "aws_s3_bucket" "logging_bucket" {
  bucket_prefix = "${local.qualified_name_prefix}-logging"
  # Uncomment to have the bucket automatically delete all objects in it when destroyed
  # By default, buckets with objects in them cannot be deleted
  #force_destroy = true

}

resource "aws_s3_bucket_policy" "log_bucket_policy" {
  bucket = aws_s3_bucket.logging_bucket.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = {
      Sid = "AllowWritesToLogBucket"
      Action = [
        "s3:PutObject",
      ]
      Effect = "Allow"
      Principal = {
        AWS = local.elb_service_account_arn
      }
      Resource = "${aws_s3_bucket.logging_bucket.arn}/*",
    }
  })
}
