
locals {
  qualified_name = "${var.name_prefix}-bloom-infra"

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
}

# resource "aws_iam_role" "full_access" {
#   name = "${local.qualified_name}-full-access"

#   assume_role_policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       # Permit CodePipeline to assume this role
#       {
#         Action = "sts:AssumeRole"
#         Effect = "Allow"
#         Principal = {
#           Service = "codepipeline.amazonaws.com"
#         }
#       }
#     ]
#   })
# }
