
locals {
  # The port for this service to listen on
  port = var.service_definition.port != null ? var.service_definition.port : 3000

  # A namespace for resources created in this module
  resource_namespace = "${var.name_prefix}-service-${var.service_definition.name}"

  # The prefix to use when saving files to upload buckets
  bucket_prefix = "${var.name_prefix}/${var.service_definition.name}"

  # The ARN pattern scoping access to the public upload bucket
  public_bucket_arn = "arn:aws:s3:::${var.public_upload_bucket}/${local.bucket_prefix}/*"

  # The ARN pattern scoping access to the secure upload bucket
  secure_bucket_arn = "arn:aws:s3:::${var.secure_upload_bucket}/${local.bucket_prefix}/*"

  # The value to use in IAM policies restricting access to upload buckets
  s3_access_policy_resource = [
    local.public_bucket_arn,
    local.secure_bucket_arn
  ]
}
