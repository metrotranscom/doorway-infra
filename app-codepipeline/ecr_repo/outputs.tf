
output "pull_policy_arn" {
  value = aws_iam_policy.pull.arn
}

output "push_policy_arn" {
  value = aws_iam_policy.push.arn
}

output "url" {
  value = local.url
}
