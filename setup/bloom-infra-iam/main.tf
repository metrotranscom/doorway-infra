
locals {
  qualified_name = "${var.name_prefix}-setup-bloom-infra"

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
