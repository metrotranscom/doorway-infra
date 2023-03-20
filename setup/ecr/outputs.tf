
output "arn" {
  value = aws_ecr_repository.repo.arn
}

output "url" {
  value = aws_ecr_repository.repo.repository_url
}
