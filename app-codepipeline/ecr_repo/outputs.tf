
output "policy_arns" {
  value = {
    push = aws_iam_policy.push.arn
    pull = aws_iam_policy.pull.arn
  }
}

output "url" {
  value = local.url
}
