
locals {
  # A namespace for resources created in this module
  resource_namespace = "${var.name_prefix}-service-${var.service_definition.name}"

  # The port for this service to listen on
  port = var.service_definition.port != null ? var.service_definition.port : 3100
  name = var.service_definition.name

  base_task = var.service_definition.task
  service   = var.service_definition.service

  # The prefix to use when saving files to upload buckets
  # Worth implmenting in the future, but requires backend changes to add prefix env var
  #bucket_prefix = "${var.name_prefix}/${var.service_definition.name}"
  bucket_prefix = ""

  # The ARN pattern scoping access to the public upload bucket
  public_bucket_arn = "arn:aws:s3:::${var.public_upload_bucket}"

  # The value to use in IAM policies restricting access to upload objects
  s3_access_policy_object_resource = [
    "${local.public_bucket_arn}/${local.bucket_prefix}/*",
    // Another can be added here in the future if files need to be uploaded to non-public bucket(s)
  ]

  # Add service-specific env vars
  env_vars = merge(
    local.base_task.env_vars,
    tomap({
      # Core Bloom vars
      PORT                = local.port,
      PARTNERS_BASE_URL   = var.partners_portal_url
      PARTNERS_PORTAL_URL = var.partners_portal_url

      # Required to start the server, but not used
      EMAIL_API_KEY     = "SG.<dummy-value>"
      APP_SECRET        = "<dummy-value-that-is-at-least-16-character-long>"
      CLOUDINARY_SECRET = "<dummy-value>"
      CLOUDINARY_KEY    = "<dummy-value>"

      # Disable color in log output
      # Makes logs more readable in CloudWatch
      NO_COLOR = "true"

      # For uploading public assets to S3
      ASSET_FS_CONFIG_s3_REGION     = "us-west-1"
      ASSET_FS_CONFIG_s3_BUCKET     = var.public_upload_bucket
      ASSET_FS_CONFIG_s3_URL_FORMAT = "public"
      # This var is not implemented yet but is included for illustration
      ASSET_FS_CONFIG_s3_PATH_PREFIX = local.bucket_prefix
    })
  )

  secrets = {
    DATABASE_URL = {
      arn = var.db.secret_arn
      key = "uri"
    }
  }

  # Set modified env_vars on task object
  task = merge(
    local.base_task,
    {
      env_vars = local.env_vars
      secrets  = local.secrets
    }
  )

  # Find which URL to provide to other services
  urls_by_listener  = module.service.urls_by_listener
  internal_alb      = var.internal_url_path[0]
  internal_listener = var.internal_url_path[1]
  internal_url_pos  = var.internal_url_path[2]

  internal_url = local.urls_by_listener[local.internal_alb][local.internal_listener][local.internal_url_pos]
}
