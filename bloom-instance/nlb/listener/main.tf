
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
}

resource "aws_lb_listener" "listener" {
  load_balancer_arn = var.nlb_arn
  port              = 443
  protocol          = "TLS"
  certificate_arn   = var.certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.nlb_to_alb.arn

  }
  tags = var.additional_tags

}





# Create ingress rules for each set of allowed CIDR blocks
resource "aws_vpc_security_group_ingress_rule" "ingress" {
  for_each = { for cidr in local.all_allowed_ips : cidr => cidr }

  security_group_id = var.security_group_id

  cidr_ipv4   = each.value
  from_port   = 443
  to_port     = 443
  ip_protocol = "TCP"

  tags = var.additional_tags
}
