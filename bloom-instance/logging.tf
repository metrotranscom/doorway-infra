resource "aws_s3_bucket" "logging_bucket" {
  bucket_prefix = "${local.project_id}-logging"
  #bucket_prefix = "${local.qualified_name_prefix}-logging"
}

resource "aws_s3_bucket_policy" "log_bucket_policy" {
  bucket = aws_s3_bucket.logging_bucket.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [for name, alb in module.albs :
      {
        Sid = "AllowWritesToLogBucket"
        Action = [
          "s3:PutObject",
        ]
        Effect = "Allow"
        Principal = {
          AWS = local.elb_service_account_arn
        }
        Resource = "arn:aws:s3:::${aws_s3_bucket.logging_bucket.bucket}/${alb.log_prefix}/AWSLogs/${local.current_account_id}/*",
      }
    ]
  })
}
