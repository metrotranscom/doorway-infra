
output "name" {
  value = aws_codebuild_project.project.name
}

output "role_arn" {
  value = aws_iam_role.codebuild.arn
}
