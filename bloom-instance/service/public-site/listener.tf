

resource "aws_lb_listener_rule" "static" {
  listener_arn = var.https_listener_arn
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
