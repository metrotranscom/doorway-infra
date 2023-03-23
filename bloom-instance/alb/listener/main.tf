
locals {
  use_tls   = var.settings.use_tls
  force_tls = local.use_tls && var.settings.force_tls

  port = var.settings.port

  allowed_subnets = var.settings.allowed_subnets

  # Combine all allowed_ips and subnets cidrs from allowed_subnets
  allowed_ips = concat(
    var.settings.allowed_ips,
    flatten([for group in local.allowed_subnets : [
      for subnet in var.subnets[group] : subnet.cidr
    ]])
  )
}

resource "aws_lb_listener" "listener" {
  load_balancer_arn = var.alb_arn
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

# Create ingress rules for each set of allowed CIDR blocks
resource "aws_vpc_security_group_ingress_rule" "ingress" {
  for_each = { for cidr in local.allowed_ips : cidr => cidr }

  security_group_id = var.security_group_id

  cidr_ipv4   = each.value
  from_port   = local.port
  to_port     = local.port
  ip_protocol = "tcp"

  tags = var.additional_tags
}
