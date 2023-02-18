terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
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
}

locals {
  default_name = "${var.resource_prefix}-${var.sdlc_stage}-${var.application_name}"

  default_tags = {
    Team        = var.team_name
    Projects    = var.project_name
    Application = var.application_name
    Environment = var.sdlc_stage
  }

  default_tags_with_name = merge(
    {
      Name = local.default_name,
    },
    local.default_tags
  )
}

# Set up our network
module "network" {
  source = "./network"

  # This defines the CIDR block allocated for our VPC, 
  # which we can then carve up into subnets
  # @NOCOMMIT -- figure out if this is right
  vpc_cidr = var.vpc_cidr

  # Pass along the standard set of tags we defined above
  tags = local.default_tags
}
