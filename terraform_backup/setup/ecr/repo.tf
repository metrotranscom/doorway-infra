
resource "aws_ecr_repository" "repo" {
  name = "${var.name_prefix}/${var.name}"

  encryption_configuration {
    encryption_type = "AES256"
  }

  image_scanning_configuration {
    scan_on_push = var.scan_images
  }
}
