
locals {
  use_tls   = var.settings.use_tls
  force_tls = local.use_tls && var.settings.force_tls
}

resource "aws_lb_listener" "listener" {
  load_balancer_arn = aws_lb.alb.arn
  port              = var.settings.port
  protocol          = local.use_tls ? "HTTPS" : "HTTP"

  default_action {
    type = "fixed-response"

    # Return a 404 status code by default
    fixed_response {
      content_type = "text/plain"
      status_code  = "404"
    }
  }

  tags = var.additional_tags
}
