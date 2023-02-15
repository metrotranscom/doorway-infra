
resource "aws_ecr_repository" "repo" {
    name = var.repo_name

    encryption_configuration {
        encryption_type = "AES256"
    }
}