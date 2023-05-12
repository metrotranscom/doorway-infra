/*
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }

  backend "s3" {
    bucket = "doorway-state"
    key    = "state/setup.tfstate"
    region = "us-west-1"
  }
}

provider "aws" {
  region = var.aws_region
}

data "aws_caller_identity" "current" {}

locals {
  account_id = var.res_acct_id != "" ? var.res_acct_id : data.aws_caller_identity.current.account_id
  arn_prefix = "arn:${var.res_acct_part}:"
  service_arn = {
    s3  = "${local.arn_prefix}s3::${local_account_id}:"
    ec2 = "${local.arn_prefix}ec2::${local_account_id}:"
  }
  arn = {
    s3_bucket      = "${local.service_arn.s3}${var.resource_prefix}*",
    vpc            = "${local.service_arn.ec2}vpc/*"
    route_table    = "${local.service_arn.ec2}route-table/*"
    security_group = "${local.service_arn.ec2}security-group/*"
  }

  request_tag_condition = {
    StringEquals = {
      "aws:RequestTag/Project" : var.project_name
    }
  }
  resource_tag_condition = {
    StringEquals = {
      "aws:ResourcewTag/Project" : var.project_name
    }
  }
}
*/
