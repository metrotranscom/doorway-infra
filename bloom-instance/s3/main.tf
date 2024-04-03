
# NOTE:
# The default implementation of the S3 bucket will not have a lot of features turned on.
# The primary use case are things like log buckets so essentiall we will just be giving people
# a KMS encrypted bucket. If you need more features they can be applied in your module with the output bucket of this one.
# trunk-ignore(checkov/CKV2_AWS_61): Lifecycle turned off - intelligent tiering used
# trunk-ignore(checkov/CKV2_AWS_62): Turning off notifcations.
# trunk-ignore(checkov/CKV_AWS_144): Turning off cross-region replication.
# trunk-ignore(checkov/CKV_AWS_18): Turning off logging
# trunk-ignore(checkov/CKV_AWS_21): Turning off versioning
resource "aws_s3_bucket" "s3_bucket" {
  # bucket_prefix is limited to 37 chars, so we have to keep this brief
  bucket_prefix = var.name
  force_destroy = var.force_destroy
}
resource "aws_s3_bucket_public_access_block" "pa_block" {
  bucket                  = aws_s3_bucket.s3_bucket.id
  block_public_acls       = var.ignore_public_acls
  block_public_policy     = var.block_public_policy
  ignore_public_acls      = var.ignore_public_acls
  restrict_public_buckets = var.restrict_public_buckets
}
resource "aws_s3_bucket_policy" "s3_bucket_policy" {
  bucket = aws_s3_bucket.s3_bucket.id
  policy = data.aws_iam_policy_document.bucket_policy_document.json

}
data "aws_iam_policy_document" "bucket_policy_document" {
  statement {
    sid    = "RequireEncryption"
    effect = "Deny"
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
    actions   = ["s3:PutObject"]
    resources = [aws_s3_bucket.s3_bucket.arn, "${aws_s3_bucket.s3_bucket.arn}/*"]
    condition {
      test     = "Null"
      variable = "s3:x-amz-server-side-encryption-aws-kms-key-id"
      values   = ["true"]
    }
  }

}
resource "aws_s3_bucket_intelligent_tiering_configuration" "it-for-entire-bucket" {
  bucket = aws_s3_bucket.s3_bucket.id
  name   = "General"
  status = var.intelligent_tiering_status
  tiering {
    access_tier = "DEEP_ARCHIVE_ACCESS"
    days        = var.intelligent_tiering_deep_archive_days
  }
  tiering {
    access_tier = "ARCHIVE_ACCESS"
    days        = var.intelligent_tiering_archive_days
  }
}
resource "aws_s3_bucket_server_side_encryption_configuration" "default_s3_encryption" {
  bucket = aws_s3_bucket.s3_bucket.id
  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = module.kms.key_id
      sse_algorithm     = "aws:kms"
    }
  }
}
# trunk-ignore(checkov/CKV_TF_1): global terraform registry doesn't use commit hash versioning
module "kms" {
  source  = "terraform-aws-modules/kms/aws"
  version = "2.2.0"
}
