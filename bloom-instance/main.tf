terraform {
  required_version = ">= 1.3"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.57.0"
    }
  }

  backend "s3" {
    bucket = "doorway-state"
    key    = "bloom/default"
    region = "us-west-1"
  }
}

provider "aws" {
  region = var.aws_region
  default_tags { tags = local.default_tags }
}

locals {
  # We may want to rearrange the order of these in the future based on how easy
  # or hard it is to read at a glance in the console.
  default_name = "${var.resource_prefix}:${terraform.workspace}-${var.sdlc_stage}:${var.application_name}"

  default_tags = {
    Team        = var.team_name
    Projects    = var.project_name
    Application = var.application_name
    Environment = var.sdlc_stage
    Workspace   = terraform.workspace
  }

  default_tags_with_name = merge(
    {
      Name = local.default_name,
    },
    local.default_tags
  )
}

module "public_sites" {
  for_each = { for idx, srv in var.public_sites : idx => srv }
  source   = "./base-service"

  name_prefix  = "doorway-${terraform.workspace}"
  service_name = each.value.name
  cpu          = each.value.cpu
  ram          = each.value.ram
  image        = each.value.image
  port         = each.value.port
  #container_port = each.value.container_port
  #alb_id         = aws_lb.alb.id

  alb_listener_arn = aws_lb_listener.alb_listener.arn
  alb_sg_id        = aws_security_group.public_alb.id
  #subnet_ids       = [for subnet in module.network.private_subnets : subnet.id]
  subnet_ids = [for subnet in aws_subnet.backend : subnet.id]

  env_vars = merge(
    tomap({
      HELLO_WORLD = "true",
    }),
    each.value.env_vars,
  )
}
