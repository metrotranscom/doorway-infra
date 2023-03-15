
resource "aws_lb" "alb" {
  name               = "${var.name_prefix}-${var.name}"
  internal           = var.internal
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]

  # Note that an ALB requires at least 2 subnets
  subnets = var.subnet_ids

  enable_deletion_protection = false

  access_logs {
    bucket  = var.log_bucket
    prefix  = local.log_prefix
    enabled = var.enable_logging
  }

  tags = var.additional_tags
}
