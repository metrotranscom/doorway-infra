
data "aws_subnet" "first" {
  id = local.subnet_ids[0]
}

locals {
  # TODO: replace this with subnet property
  vpc_id = data.aws_subnet.first.vpc_id

  default_name = "${var.name_prefix}-srv-${local.name}"

  task_id = var.task_arn

  # Extract definition vars to simplify naming throughout
  name         = var.service.name
  port         = var.service.port
  protocol     = var.service.protocol
  health_check = var.service.health_check

  requested_albs = var.service.albs

  filtered_albs = { for alb_name, alb in var.alb_map : alb_name => alb if try(local.requested_albs[alb_name] != null, false) }

  rule_map = merge([for alb_name, alb in local.requested_albs : {
    for listener_name, listener in alb.listeners : "${alb_name}-${listener_name}" => {
      arn     = var.alb_map[alb_name].listeners[listener_name].arn
      domains = listener.domains
    }
  }]...)

  # Generate URLs that can be used to access this service
  urls_by_listener = { for alb_name, alb in local.requested_albs : alb_name => {
    for listener_name, listener in alb.listeners : listener_name => [
      # Add ALB DNS name to list of domains and format them into URLs
      for domain in concat(listener.domains, [var.alb_map[alb_name].dns_name]) : join("", [
        # We need to look up info about the listener to determine how to put together our URL
        var.alb_map[alb_name].listeners[listener_name].is_secure ? "https" : "http",
        "://",
        domain,
        ":${var.alb_map[alb_name].listeners[listener_name].port}"
      ])
    ]
  } }

  security_group_ids = toset([for alb in local.filtered_albs : alb.security_group.id])

  subnet_ids = [for subnet in var.subnet_map[var.service.subnet_group] : subnet.id]
}
