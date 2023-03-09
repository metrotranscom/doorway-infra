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
  default_name = "${var.name_prefix}-${terraform.workspace}"

  default_tags = {
    Team        = var.team_name
    Project     = var.project_name
    Project     = var.project_name
    Application = var.application_name
    Environment = var.sdlc_stage
    Workspace   = terraform.workspace
  }

  /*
  /*
  default_tags_with_name = merge(
    {
      Name = local.default_name,
    },
    local.default_tags
  )
  */
}

module "network" {
  source = "./network"

  name_prefix = local.default_name
  vpc_cidr    = var.vpc_cidr
  subnet_map  = var.subnet_map
}

module "public_alb" {
  source = "./alb"

  name_prefix = local.default_name
  name        = "Public"
  vpc_id      = module.network.vpc.id
  subnet_ids  = [for subnet in module.network.subnets.public : subnet.id]

  listeners = {
    public = {
      port        = 80
      use_tls     = false
      allowed_ips = ["0.0.0.0/0"]
    }
    internal = {
      port        = 8080
      use_tls     = false
      allowed_ips = [for subnet in module.network.subnets.app : subnet.cidr_block]
    }
  }

}
