
module "s3_logging" {
  source = "../modules/s3"
  prefix =  "${local.qualified_name_prefix}-logging"
}

resource "aws_s3_bucket_policy" "log_bucket_policy" {
  bucket = module.s3_logging.bucket.id

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
        Resource = "${module.s3.bucket.arn}/${alb.log_prefix}/AWSLogs/${local.current_account_id}/*",
      }
    ]
  })
}
