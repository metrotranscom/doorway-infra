resource "aws_lb_target_group" "service" {
  # Only alphanumeric characters and hyphens
  name        = local.default_name
  port        = var.service.port
  protocol    = var.service.health_check.protocol
  vpc_id      = var.vpc_id
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
