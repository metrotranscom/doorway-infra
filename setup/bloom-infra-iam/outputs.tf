
output "policy_arns" {
  value = {
    read : aws_iam_policy.read.arn
    create : aws_iam_policy.create.arn
    modify : aws_iam_policy.modify.arn
  }
}
