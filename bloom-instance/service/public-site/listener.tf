resource "aws_lb_listener" "listener" {
  load_balancer_arn = var.alb_arn
  port              = 443
  protocol          = "HTTPS"
  certificate_arn   = var.cert_arn

  default_action {
    type = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      message_body = "Fixed response content"
      status_code  = "200"
    }

  }

  tags = var.additional_tags
}


resource "aws_lb_listener_rule" "static" {
  listener_arn = aws_lb_listener.listener.arn
  priority     = 100

  action {
    type             = "forward"
    target_group_arn = module.service.target_group.arn
  }

  condition {
    host_header {
      values = var.site_urls
    }
  }
}
