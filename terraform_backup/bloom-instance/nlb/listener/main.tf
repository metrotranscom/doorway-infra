
locals {



  # Same for allowed ips and subnets
  allowed_ips     = var.allowed_ips != null ? var.allowed_ips : []
  allowed_subnets = var.allowed_subnets != null ? var.allowed_subnets : []




  # Combine all allowed_ips and subnets cidrs from allowed_subnets
  all_allowed_ips = concat(
    local.allowed_ips,
    flatten([for group in local.allowed_subnets : [
      for subnet in var.subnets[group] : subnet.cidr
    ]])
  )
}
resource "aws_lb_target_group" "nlb_to_alb" {
  name        = "${var.name_prefix}-nlb-alb"
  target_type = "alb"
  port        = 443
  protocol    = "TCP"
  vpc_id      = var.vpc_id
  health_check {
    protocol = "HTTPS"

  }
}

resource "aws_lb_listener" "listener" {
  load_balancer_arn = var.nlb_arn
  port              = 443
  protocol          = "TCP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.nlb_to_alb.arn

  }
  tags = var.additional_tags

}
resource "aws_lb_target_group_attachment" "attach_target" {
  target_group_arn = aws_lb_target_group.nlb_to_alb.arn
  target_id        = var.alb_arn

}




