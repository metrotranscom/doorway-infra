
resource "aws_lb_listener" "alb_listeners" {
  for_each          = { for k, v in var.listeners : k => v }
  load_balancer_arn = aws_lb.alb.arn
  port              = each.value.port
  protocol          = each.value.use_tls ? "HTTPS" : "HTTP"

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
