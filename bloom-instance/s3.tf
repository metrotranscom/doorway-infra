resource "aws_s3_bucket" "public_uploads" {
  bucket_prefix = "${local.qualified_name_prefix}-public-uploads"
}

resource "aws_s3_bucket" "secure_uploads" {
  bucket_prefix = "${local.qualified_name_prefix}-secure-uploads"
}

resource "aws_s3_bucket" "static_content" {
  bucket_prefix = "${local.qualified_name_prefix}-static-content"
}

resource "aws_s3_bucket_public_access_block" "public_uploads" {
  bucket = aws_s3_bucket.public_uploads.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

# Allow anyone to read from the public uploads bucket
resource "aws_s3_bucket_policy" "public_uploads" {
  bucket = aws_s3_bucket.public_uploads.id
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
        Resource  = "${aws_s3_bucket.public_uploads.arn}/*",
      },
    ]
  })

  depends_on = [aws_s3_bucket_public_access_block.public_uploads]
}
