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
    Application = var.application_name
    Environment = var.sdlc_stage
    Workspace   = terraform.workspace
  }
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
  name        = "public"
  vpc_id      = module.network.vpc.id
  subnet_ids  = [for subnet in module.network.subnets.public : subnet.id]

  listeners = {
    public = {
      port        = 80
      use_tls     = false
      allowed_ips = ["0.0.0.0/0"]
    }

    # internal is here just to provide an easy path forward if we want an internal route to services
    internal = {
      port        = 8080
      use_tls     = false
      allowed_ips = [for subnet in module.network.subnets.app : subnet.cidr_block]
    }
  }
}

module "public_sites" {
  for_each = { for idx, srv in var.public_sites : idx => srv }
  source   = "./public-site"

  name_prefix        = local.default_name
  service_definition = each.value

  alb_listener_arn = module.public_alb.listeners.public.arn
  alb_sg_id        = module.public_alb.security_group.id
  subnet_ids       = [for subnet in module.network.subnets.app : subnet.id]

  public_upload_bucket_name = aws_s3_bucket.user_upload_bucket.name
  secure_upload_bucket_name = aws_s3_bucket.user_upload_bucket.name

  # Just a placeholder for now
  backend_api_base = "http://localhost:3100"

  additional_tags = {
    ServiceType = "public-site"
    ServiceName = each.value.name
  }
}
