resource "aws_s3_bucket" "logging_bucket" {
  bucket_prefix = "${local.qualified_name_prefix}-logging"
  # Uncomment to have the bucket automatically delete all objects in it when destroyed
  # By default, buckets with objects in them cannot be deleted
  #force_destroy = true

}
data "aws_iam_policy_document" "accessdocument" {
  statement {
    sid = "BucketLoggingAccess"
    principals {
      type        = "AWS"
      identifiers = [local.elb_service_account_arn]
    }
    actions = ["s3:PutObject", ]
    resources = [
      aws_s3_bucket.logging_bucket.arn,
      "${aws_s3_bucket.logging_bucket.arn}/*"
    ]
  }
  statement {
    sid = "AWSLogDeliveryAclCheck"
    principals {
      type        = "AWS"
      identifiers = [local.elb_service_account_arn]
    }
    actions = ["s3:GetBucketAcl", ]
    resources = [
      aws_s3_bucket.logging_bucket.arn,
      "${aws_s3_bucket.logging_bucket.arn}/*"
    ]
    condition {
      test     = "ForAnyValue:StringEquals"
      variable = "aws:SourceAccount"
      values   = [local.aws_account]
    }
    condition {
      test     = "ForAnyValue:ArnLike"
      variable = "aws:SourceArn"
      values   = ["arn:aws:logs:${local.aws_region}:${local.aws_account}:*"]
    }

  }
  statement {
    sid = "AWSLogDeliveryWrite"
    principals {
      type        = "Service"
      identifiers = ["delivery.logs.amazonaws.com"]
    }
    actions = ["s3:PutObject", ]
    resources = [
      aws_s3_bucket.logging_bucket.arn,
      "${aws_s3_bucket.logging_bucket.arn}/*"
    ]
    condition {
      test     = "StringEquals"
      variable = "aws:SourceAccount"
      values   = [local.aws_account]
    }
    condition {
      test     = "ArnLike"
      variable = "aws:SourceArn"
      values   = ["arn:aws:logs:${local.aws_region}:${local.aws_account}:*"]
    }
    condition {
      test     = "StringEquals"
      variable = "s3:x-amz-acl"
      values   = ["bucket-owner-full-control"]
    }

  }


}

resource "aws_s3_bucket_policy" "log_bucket_policy" {
  bucket = aws_s3_bucket.logging_bucket.id

  policy = data.aws_iam_policy_document.accessdocument.json

}
