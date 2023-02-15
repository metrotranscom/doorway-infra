
variable "aws_region" {
  type        = string
  description = "The AWS region to deploy into"
}

variable "repo_name" {
  type        = string
  description = "The name of the ECR repository"
}