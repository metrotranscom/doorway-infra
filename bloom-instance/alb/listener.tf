
/*
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
*/

module "listeners" {
  source = "./listener"

  for_each = { for k, v in var.listeners : k => v }

  subnets           = var.subnets
  alb_arn           = aws_lb.alb.arn
  security_group_id = aws_security_group.alb.id

  settings = each.value

  additional_tags = var.additional_tags

  /*
  port             = each.value.port
  use_tls          = each.value.use_tls
  force_tls        = each.value.force_tls
  default_cert     = each.value.default_cert
  additional_certs = optional(list(string))
  allowed_ips      = list(string)
  allowed_subnets  = list(string)
  */

}
