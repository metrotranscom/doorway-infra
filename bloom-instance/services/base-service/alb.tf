
resource "aws_lb_target_group" "service" {
  # Only alphanumeric characters and hyphens
  name        = local.default_name
  port        = local.port
  protocol    = local.protocol
  vpc_id      = local.vpc_id
  target_type = "ip"

  load_balancing_algorithm_type = "least_outstanding_requests"

  health_check {
    # Health checks are required for target_type = "ip"
    enabled = true

    interval = local.health_check.interval
    matcher  = join(",", local.health_check.valid_status)
    path     = local.health_check.path
    protocol = local.health_check.protocol
    timeout  = local.health_check.timeout

    healthy_threshold   = local.health_check.healthy_threshold
    unhealthy_threshold = local.health_check.unhealthy_threshold
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
      values = local.domains
    }
  }

  tags = var.additional_tags
}
