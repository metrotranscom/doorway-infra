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
