terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}
locals {
  # This provides a unique, consistent, and meaningful name prefix for resources
  qualified_name = "${var.name_prefix}-setup-bloom-infra"
  group_path     = "/${var.project_id}/${var.environment}/"

  # We know the Bloom infra terraform creates S3 buckets with this prefix
  arn_resource_prefix = "${var.project_id}-${var.environment}"
  # This cannot contain a region or account ID
  s3_bucket_arn = "arn:aws:s3:::${local.arn_resource_prefix}"

  # These are services that we need to ability to pass IAM roles to
  pass_role_services = [
    "ecs.amazonaws.com",
    "ecs-tasks.amazonaws.com",
    "scheduler.amazonaws.com",
    "ecs.application-autoscaling.amazonaws.com"
  ]

  used_service_roles = [
    "rds.amazonaws.com/AWSServiceRoleForRDS",
    "ecs.application-autoscaling.amazonaws.com/AWSServiceRoleForApplicationAutoScaling_ECSService"
  ]

  service_role_arns = [
    for role in local.used_service_roles :
    "arn:aws:iam::${var.infra_account_id}:role/aws-service-role/${role}"
  ]

  # Only permit the creation of resources with both the ProjectID and Environment variables
  default_create_condition = {
    StringEquals : {
      "aws:RequestTag/ProjectID" : var.project_id
      "aws:RequestTag/Environment" : var.environment
    }
  }

  default_modify_condition = {
    StringEquals : {
      "aws:ResourceTag/ProjectID" : var.project_id
      "aws:ResourceTag/Environment" : var.environment
    }
  }

  policy_arns = {
    read : aws_iam_policy.read.arn
    create : aws_iam_policy.create.arn
    modify : aws_iam_policy.modify.arn
  }
}

# Create a group with read-only access
resource "aws_iam_group" "read_only" {
  name = "${local.qualified_name}-read-only"
  path = local.group_path
}


# Attach the "read" policy to the "read-only" group
resource "aws_iam_group_policy_attachment" "read_only" {
  group      = aws_iam_group.read_only.name
  policy_arn = aws_iam_policy.read.arn
}

# Create a group with read and write access
resource "aws_iam_group" "read_write" {
  name = "${local.qualified_name}-read-write"
  path = local.group_path
}

# Assign all policies here to the read-write group
resource "aws_iam_group_policy_attachment" "read_write" {
  for_each   = local.policy_arns
  group      = aws_iam_group.read_write.name
  policy_arn = each.value
}
