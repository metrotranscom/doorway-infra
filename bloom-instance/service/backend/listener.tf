resource "aws_lb_listener" "listener" {
  load_balancer_arn = var.alb_arn
  port              = 443
  protocol          = "HTTPS"
  certificate_arn   = var.cert_arn

  default_action {
    type             = "forward"
    target_group_arn = module.service.target_group.arn
  }

  tags = var.additional_tags
}
