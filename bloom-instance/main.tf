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


# Needed to resolve current AWS Account ID for policy documents
data "aws_caller_identity" "current" {}

# ELBs have special rules for granting access for logging purposes
# https://docs.aws.amazon.com/elasticloadbalancing/latest/application/enable-access-logging.html
data "aws_elb_service_account" "current" {}

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

  #The ID for the Account that our resources are being deployed into
  current_account_id = data.aws_caller_identity.current.account_id

  # The Account ID for the AWS ELB service in this region
  elb_service_account_arn = data.aws_elb_service_account.current.arn

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
  use_ngw     = var.use_ngw
}

module "public_alb" {
  source = "./alb"

  name_prefix = local.default_name
  name        = "public"
  vpc_id      = module.network.vpc.id
  subnet_ids  = [for subnet in module.network.subnets.public : subnet.id]

  enable_logging = true
  log_bucket     = aws_s3_bucket.logging_bucket.bucket

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

# There may be multiple public sites
module "public_sites" {
  for_each = { for idx, srv in var.public_sites : idx => srv }
  source   = "./services/public-site"

  name_prefix        = local.default_name
  service_definition = each.value

  alb_listener_arn = module.public_alb.listeners.public.arn
  alb_sg_id        = module.public_alb.security_group.id
  subnet_ids       = [for subnet in module.network.subnets.app : subnet.id]

  public_upload_bucket = aws_s3_bucket.user_upload_bucket.bucket
  secure_upload_bucket = aws_s3_bucket.user_upload_bucket.bucket

  # Just a placeholder for now
  backend_api_base = "http://localhost:3100"

  additional_tags = {
    ServiceType = "public-site"
    ServiceName = each.value.name
  }
}

# So far, there only seems to be a need for a single partner site
module "partner_site" {
  source = "./services/partner-site"

  name_prefix        = local.default_name
  service_definition = var.partner_site

  alb_listener_arn = module.public_alb.listeners.public.arn
  alb_sg_id        = module.public_alb.security_group.id
  subnet_ids       = [for subnet in module.network.subnets.app : subnet.id]

  public_upload_bucket = aws_s3_bucket.user_upload_bucket.bucket
  secure_upload_bucket = aws_s3_bucket.user_upload_bucket.bucket

  # Just a placeholder for now
  backend_api_base = "http://localhost:3100"

  additional_tags = {
    ServiceType = "partner-site"
    ServiceName = var.partner_site.name
  }
}

output "dns_zones" {
  value = { for k, v in module.dns_zones : k => v.zone_id }
}
