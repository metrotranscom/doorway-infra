
resource "aws_lb_target_group" "service" {
  # Only alphanumeric characters and hyphens
  name        = "${var.name_prefix}-${var.service_name}"
  port        = var.port
  protocol    = var.service_protocol
  vpc_id      = local.vpc_id
  target_type = "ip"

  tags = var.additional_tags
}

resource "aws_lb_listener_rule" "service" {
  listener_arn = var.alb_listener_arn

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.service.arn
  }

  condition {
    host_header {
      values = var.host_patterns
    }

    /*
    path_pattern {
      values = var.path_patterns
    }
    */
  }

  tags = var.additional_tags
}
