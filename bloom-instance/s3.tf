
module "s3_public_uploads" {
  source = "../modules/s3"
  prefix =  "${local.qualified_name_prefix}-public-uploads"
  force_destroy = false
}

module "s3_secure_uploads" {
  source = "../modules/s3"
  prefix =  "${local.qualified_name_prefix}-secure-uploads"
  force_destroy = false
}

module  "s3_static_content" {
  source = "../modules/s3"
  prefix = "${local.qualified_name_prefix}-static-content"
}
# trunk-ignore(checkov/CKV_AWS_53): Public upload bucket
# trunk-ignore(checkov/CKV_AWS_54): Public upload bucket
# trunk-ignore(checkov/CKV_AWS_55): Public upload bucket
# trunk-ignore(checkov/CKV_AWS_56): Public upload bucket
resource "aws_s3_bucket_public_access_block" "public_uploads" {
  bucket = module.s3_public_uploads.bucket.id
  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

# Allow anyone to read from the public uploads bucket
# trunk-ignore(checkov/CKV_AWS_70): public download bucket. needs universal read
resource "aws_s3_bucket_policy" "public_uploads" {
  bucket = module.s3_public_uploads.bucket.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid = "AllowReadsFromUploadBucket"
        Action = [
          "s3:GetObject",
        ]
        Effect    = "Allow"
        Principal = "*"
        Resource  = "${module.s3_public_uploads.bucket.arn}/*",
      },
    ]
  })

  depends_on = [aws_s3_bucket_public_access_block.public_uploads]
}
