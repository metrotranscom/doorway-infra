
resource "aws_ecr_repository" "repo" {
  name = local.name_prefix

  encryption_configuration {
    encryption_type = "AES256"
  }

  image_scanning_configuration {
    scan_on_push = var.scan_images
  }
}
