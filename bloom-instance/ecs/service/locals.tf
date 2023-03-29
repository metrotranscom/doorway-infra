
data "aws_subnet" "first" {
  id = local.subnet_ids[0]
}

locals {
  # TODO: replace this with subnet property
  vpc_id = data.aws_subnet.first.vpc_id

  default_name = "${var.name_prefix}-srv-${local.name}"

  task_id = var.task_arn

  # Extract definition vars to simplify naming throughout
  name     = var.service.name
  port     = var.service.port
  protocol = var.service.protocol
  #domains      = var.service.domains
  health_check = var.service.health_check

  #filtered_albs = [for name, alb in var.service.albs : var.albs[name]]

  requested_albs = var.service.albs

  # filtered_albs = { for alb_name, alb in var.alb_map : alb_name => {
  #   listeners = { for listener_name, listener in alb.listeners : listener_name => {
  #     arn     = alb.listeners[listener].arn
  #     domains = local.requested_albs[alb_name].listeners[listener]
  #   } if try(local.requested_albs[alb_name].listeners[listener_name] != null, false) }
  #   security_group = var.alb_map[alb_name].security_group
  #   } if try(local.requested_albs[alb_name] != null, false)
  # }

  filtered_albs = { for alb_name, alb in var.alb_map : alb_name => alb if try(local.requested_albs[alb_name] != null, false) }
  /*
  merged_albs = { for alb_name, alb in local.filtered_albs : alb_name => {
    listeners = { for listener_name, listener in alb.listeners : listener_name => {
      arn     = listener.arn
      domains = local.requested_albs[alb_name].listeners[listener].domains
    } if try(local.requested_albs[alb_name].listeners[listener_name] != null && local.requested_albs[alb_name].listeners[listener].domains != null, false) }
    security_group = alb.security_group
    }
  }
  */

  rule_map = merge([for alb_name, alb in local.requested_albs : {
    for listener_name, listener in alb.listeners : "${alb_name}-${listener_name}" => {
      arn     = var.alb_map[alb_name].listeners[listener_name].arn
      domains = listener.domains
    }
  }]...)

  security_group_ids = toset([for alb in local.filtered_albs : alb.security_group.id])

  subnet_ids = [for subnet in var.subnet_map[var.service.subnet_group] : subnet.id]
}
