
resource "aws_lb" "alb" {
  name               = "${var.name_prefix}-${var.name}"
  internal           = var.internal
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]

  # Note that an ALB requires at least 2 subnets
  subnets = var.subnet_ids

  enable_deletion_protection = false

  /* TODO
  access_logs {
    bucket  = aws_s3_bucket.logging_bucket.id
    prefix  = "public-alb-logs"
    enabled = true
  }
  */

  tags = var.additional_tags
}
