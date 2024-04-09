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
    },
    Statement = {
      Sid = "AWSLogDeliveryAclCheck"
      Action = [
        "s3:GetBucketAcl",
      ]
      Effect = "Allow"
      Principal = {
        Service = "delivery.logs.amazonaws.com"
      }
      Resource = "${aws_s3_bucket.logging_bucket.arn}/*",
      condition = {
        test     = "ForAnyValue:StringEquals"
        variable = "aws:SourceAccount"
        values   = [local.aws_account]
      },
      condition = {
        test     = "ForAnyValue:ArnLike"
        variable = "aws:SourceArn"
        values   = ["arn:aws:logs:${local.aws_region}:${local.aws_account}:*"]
      }
    },
    Statement = {
      Sid = "AWSLogDeliveryAclCheck"
      Action = [
        "s3:PutObject",
      ]
      Effect = "Allow"
      Principal = {
        Service = "delivery.logs.amazonaws.com"
      }
      Resource = "${aws_s3_bucket.logging_bucket.arn}/*",
      condition = {
        test     = "ForAnyValue:StringEquals"
        variable = "s3:x-amz-acl"
        values   = ["bucket-owner-full-control"]
      },
      condition = {
        test     = "ForAnyValue:StringEquals"
        variable = "aws:SourceAccount"
        values   = [local.aws_account]
      },
      condition = {
        test     = "ForAnyValue:ArnLike"
        variable = "aws:SourceArn"
        values   = ["arn:aws:logs:${local.aws_region}:${local.aws_account}:*"]
      }
    }

  })
}
