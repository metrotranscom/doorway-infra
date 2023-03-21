
data "aws_subnet" "first" {
  id = var.subnet_ids[0]
}

locals {
  # This saves us an input var
  vpc_id = data.aws_subnet.first.vpc_id

  default_name = "${var.name_prefix}-srv-${local.name}"

  # Extract definition vars to simplify naming throughout
  name         = var.service_definition.name
  cpu          = var.service_definition.cpu
  ram          = var.service_definition.ram
  image        = var.service_definition.image
  port         = var.service_definition.port
  protocol     = var.service_definition.protocol
  domains      = var.service_definition.domains
  env_vars     = var.service_definition.env_vars
  health_check = var.service_definition.health_check

  # Check the image name to see if it resides in an ECR repo
  # If so, add permssions for our service to access the repo
  ecr_regex      = "^(?P<account>[0-9]{12})\\.dkr\\.ecr\\.(?P<region>[a-z]+\\-[a-z]+\\-[0-9])\\.amazonaws\\.com\\/(?P<repo>[0-9a-z\\-\\/]+):(?P<tag>[\\w\\-\\.]+)$"
  ecr_regex_test = regexall(local.ecr_regex, local.image)
  is_ecr         = length(local.ecr_regex_test) > 0
  ecr_repo       = local.is_ecr ? local.ecr_regex_test[0] : null
}
