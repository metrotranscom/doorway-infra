
resource "aws_lb_target_group" "service" {
  # Only alphanumeric characters and hyphens
  name        = "${var.name_prefix}-${var.service_name}"
  port        = var.port
  protocol    = var.service_protocol
  vpc_id      = local.vpc_id
  target_type = "ip"

  load_balancing_algorithm_type = "least_outstanding_requests"

  health_check {
    enabled  = var.health_check.enabled
    interval = var.health_check.interval
    matcher  = join(",", var.health_check.valid_status)
    path     = var.health_check.path
    protocol = var.health_check.protocol
    timeout  = var.health_check.timeout

    healthy_threshold   = var.health_check.healthy_threshold
    unhealthy_threshold = var.health_check.unhealthy_threshold
  }

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
