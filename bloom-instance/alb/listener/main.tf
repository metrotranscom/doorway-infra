
locals {
  use_tls   = var.settings.use_tls
  force_tls = local.use_tls && var.settings.force_tls

  allowed_ips     = var.settings.allowed_ips
  allowed_subnets = var.settings.allowed_subnets
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

# Create one ingress rule for each listener/port/ip combination
resource "aws_vpc_security_group_ingress_rule" "ingress" {
  for_each = { for pm in local.port_mappings : "${pm.name}-${pm.port}-${pm.cidr}" => pm }

  security_group_id = aws_security_group.alb.id

  cidr_ipv4   = each.value.cidr
  from_port   = each.value.port
  to_port     = each.value.port
  ip_protocol = "tcp"

  tags = var.additional_tags
}
