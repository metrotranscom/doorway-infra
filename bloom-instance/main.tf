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
  region = tags.aws_region

  default_tags {
    tags = {
      Team = tags.team_name
      Projects = tags.project_name
      Application = tags.application_name
      Environment = tags.sdlc_stage
    }
  }
}
