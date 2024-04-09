
locals {

  # Terraform does not apply variable defaults if a null value is passed
  # Set the default for var.tls here
  tls = var.tls != null ? var.tls : {
    enable           = false
    default_cert     = null
    additional_certs = []
  }

  # Same for allowed ips and subnets
  allowed_ips     = var.allowed_ips != null ? var.allowed_ips : []
  allowed_subnets = var.allowed_subnets != null ? var.allowed_subnets : []

  # Shortcuts for TLS settings
  use_tls   = local.tls.enable
  force_tls = !local.use_tls && var.default_action == "force-tls"

  # If default_action is "force-tls", the default action should be to redirect to the HTTPS version of the site
  default_action = local.force_tls ? {
    type = "redirect"
    redirect = {
      proto       = "HTTPS"
      port        = 443 # TODO: make this configurable
      status_code = "HTTP_302"
    }
    response = null
    } : { # Otherwise, just return a 404
    type     = "fixed-response"
    redirect = null
    response = {
      content_type = "text/plain"
      status_code  = "404"
    }
  }

  port = var.port

  # Combine all allowed_ips and subnets cidrs from allowed_subnets
  all_allowed_ips = concat(
    local.allowed_ips,
    flatten([for group in local.allowed_subnets : [
      for subnet in var.subnets[group] : subnet.cidr
    ]])
  )
}

resource "aws_lb_listener" "listener" {
  load_balancer_arn = var.nlb_arn
  port              = local.port
  protocol          = local.use_tls ? "HTTPS" : "HTTP"
  certificate_arn   = local.tls.default_cert != null ? var.cert_map[local.tls.default_cert] : null

  default_action {
    type = local.default_action.type

    dynamic "fixed_response" {
      for_each = local.default_action.response != null ? [local.default_action.response] : []
      iterator = response

      content {
        content_type = response.value.content_type
        status_code  = response.value.status_code
      }
    }

    dynamic "redirect" {
      for_each = local.default_action.redirect != null ? [local.default_action.redirect] : []
      iterator = redirect

      content {
        protocol    = redirect.value.proto
        port        = redirect.value.port
        status_code = redirect.value.status_code
      }
    }
  }

  tags = var.additional_tags
}

resource "aws_lb_listener_certificate" "listener" {
  for_each = { for cert_name in local.tls.additional_certs : cert_name => var.cert_map[cert_name] }

  listener_arn    = aws_lb_listener.listener.arn
  certificate_arn = each.value
}

# Create ingress rules for each set of allowed CIDR blocks
resource "aws_vpc_security_group_ingress_rule" "ingress" {
  for_each = { for cidr in local.all_allowed_ips : cidr => cidr }

  security_group_id = var.security_group_id

  cidr_ipv4   = each.value
  from_port   = local.port
  to_port     = local.port
  ip_protocol = "tcp"

  tags = var.additional_tags
}
