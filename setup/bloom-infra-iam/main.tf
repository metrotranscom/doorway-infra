
locals {
  # This provides a unique, consistent, and meaningful name prefix for resources
  qualified_name = "${var.name_prefix}-setup-bloom-infra"

  # We know the Bloom infra terraform creates S3 buckets with this prefix
  s3_bucket_prefix = "${var.project_id}-${var.environment}"
  # This cannot contain a region or account ID
  s3_bucket_arn    = "arn:aws:s3:::${local.s3_bucket_prefix}"

  # These are services that we need to ability to pass IAM roles to
  pass_role_services = [
    "ecs.amazonaws.com",
    "ecs-tasks.amazonaws.com",
    "scheduler.amazonaws.com"
  ]

  used_service_roles = [
    "rds.amazonaws.com/AWSServiceRoleForRDS"
  ]

  service_role_arns = [
    for role in local.used_service_roles :
    "arn:aws:iam:${var.infra_region}:${var.infra_account_id}:role/aws-service-role/${role}"
  ]

  default_read_condition = {
    StringEquals : {
      "aws:RequestTag/ProjectID" : var.project_id
      #"aws:RequestTag/Environment" : var.environment
    }
  }

  # Only permit the creation of resources with both the ProjectID and Environment variables
  default_create_condition = {
    StringEquals : {
      "aws:RequestTag/ProjectID" : var.project_id
      #"aws:RequestTag/Environment" : var.environment
    }
  }

  default_modify_condition = {
    StringEquals : {
      "aws:ResourceTag/ProjectID" : var.project_id
      #"aws:ResourceTag/Environment" : var.environment
    }
  }
}

# Could create a role that has all policies attached by default
# resource "aws_iam_role" "full_access" {
#   name = "${local.qualified_name}-full-access"

#   assume_role_policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Action = "sts:AssumeRole"
#         Effect = "Allow"
#         Principal = ""
#       }
#     ]
#   })
# }
