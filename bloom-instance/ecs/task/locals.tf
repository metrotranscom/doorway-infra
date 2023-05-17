
data "aws_region" "current" {}

locals {
  default_name = "${var.name_prefix}-task-${local.name}"

  # Extract definition vars to simplify naming throughout
  name     = var.task.name
  cpu      = var.task.cpu
  ram      = var.task.ram
  image    = var.task.image
  port     = var.task.port
  env_vars = var.task.env_vars
  secrets  = var.task.secrets

  # Check the image name to see if it resides in an ECR repo
  # If so, add permssions for our service to access the repo
  ecr_regex      = "^(?P<account>[0-9]{12})\\.dkr\\.ecr\\.(?P<region>[a-z]+\\-[a-z]+\\-[0-9])\\.amazonaws\\.com\\/(?P<repo>[0-9a-z\\-\\/]+):(?P<tag>[\\w\\-\\.]+)$"
  ecr_regex_test = regexall(local.ecr_regex, local.image)
  is_ecr         = length(local.ecr_regex_test) > 0
  ecr_repo       = local.is_ecr ? local.ecr_regex_test[0] : null

  log = {
    group         = "${var.name_prefix}-tasks"
    region        = data.aws_region.current.name
    stream_prefix = local.name
  }

  # Find all unique secrets arns so we can create permissions to access them
  unique_secret_arns = distinct([for secret in local.secrets : secret.arn])

  has_secrets = length(local.secrets) > 0
}
