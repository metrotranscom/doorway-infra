
output "repo_arn" {
    value = aws_ecr_repository.repo.arn
}

output "repo_url" {
    value = aws_ecr_repository.repo.repository_url
}