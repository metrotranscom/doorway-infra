resource "aws_s3_bucket" "public_uploads" {
  bucket_prefix = "${var.name_prefix}-public-uploads"
}

resource "aws_s3_bucket" "secure_uploads" {
  bucket_prefix = "${var.name_prefix}-secure-uploads"
}

resource "aws_s3_bucket" "static_content" {
  bucket_prefix = "${var.name_prefix}-static-content"
}

# Allow anyone to read from the public uploads bucket
resource "aws_s3_bucket_policy" "public_uploads" {
  bucket = aws_s3_bucket.bucket.id
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
        Resource  = "arn:aws:s3:${var.aws_region}::${aws_s3_bucket.public_uploads.bucket}/*",
      },
    ]
  })
}
