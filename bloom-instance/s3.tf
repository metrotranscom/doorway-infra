resource "aws_s3_bucket" "user_upload_bucket" {
  bucket_prefix = "${var.name_prefix}-user-uploads"
}

resource "aws_s3_bucket_cors_configuration" "user_upload_cors_config" {
  bucket = aws_s3_bucket.user_upload_bucket.id

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["PUT", "GET"]
    allowed_origins = ["http://localhost:3001"]
    expose_headers  = []
  }
}

resource "aws_s3_bucket_policy" "allow_public_access" {
  bucket = aws_s3_bucket.user_upload_bucket.id
  policy = data.aws_iam_policy_document.allow_public_access_policy.json
}

data "aws_iam_policy_document" "allow_public_access_policy" {
  statement {
    principals {
      type        = "*"
      identifiers = ["*"]
    }

    effect = "Allow"

    actions = [
      "s3:GetObject",
      "s3:PutObject",
    ]

    resources = [
      aws_s3_bucket.user_upload_bucket.arn,
      "${aws_s3_bucket.user_upload_bucket.arn}/*",
    ]
  }
}
