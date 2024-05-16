
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
  cluster_name = var.service.cluster_name

  requested_albs = var.service.albs

  filtered_albs = { for alb_name, alb in var.alb_map : alb_name => alb if try(local.requested_albs[alb_name] != null, false) }

  # # # Sort out domains by listener
  # domains_by_listener = { for alb_name, alb in local.requested_albs : alb_name => {
  #   for listener_name, listener in alb.listeners :
  #   # If listener.listen_on_alb_dns_name is true, add the ALB DNS name to the list of domains
  #   listener_name => listener.listen_on_alb_dns_name ?
  #   concat(listener.domains, [var.alb_map[alb_name].dns_name]) :
  #   listener.domains
  # } }

  # rule_map = merge([for alb_name, alb in local.requested_albs : {
  #   for listener_name, listener in alb.listeners : "${alb_name}-${listener_name}" => {
  #     arn = var.alb_map[alb_name].listeners[listener_name].arn
  #     # Use domains_by_listener so we make sure to include ALB DNS name if needed
  #     domains = local.domains_by_listener[alb_name][listener_name]
  #   }
  # }]...)

  # #Generate URLs that can be used to access this service
  # urls_by_listener = { for alb_name, alb in local.filtered_albs : alb_name => {
  #   for listener_name, listener in local.requested_albs[alb_name].listeners : listener_name => [
  #     for domain in local.domains_by_listener[alb_name][listener_name] : join("", [
  #       # We need to look up info about the listener to determine how to put together our URL
  #       # If is_secure is true, use the https proto, otherwise use http
  #       alb.listeners[listener_name].is_secure ? "https" : "http",
  #       "://",
  #       domain,
  #       # Add the port if non-standard
  #       (alb.listeners[listener_name].port == 443 &&
  #       alb.listeners[listener_name].is_secure) ||
  #       alb.listeners[listener_name].port == 80
  #       ? "" : ":${alb.listeners[listener_name].port}"
  #     ])
  #   ]
  # } }

  # Collapse all URLs into a single list
  # url_list = flatten([for alb_name, by_listener in local.urls_by_listener : [
  #   for urls in by_listener : urls
  # ]])

  # security_group_ids = toset([for alb in local.filtered_albs : alb.security_group.id])

  subnet_ids = [for subnet in var.subnet_map[var.service.subnet_group] : subnet.id]

  # Autoscaling
  scaling     = var.service.scaling
  use_scaling = local.scaling.enabled
  # If the desired count is less than the min, make min the desired count
  desired_count       = local.scaling.desired < local.scaling.min ? local.scaling.min : local.scaling.desired
  autoscaling_metrics = (local.use_scaling ? local.scaling.metrics : {})
}
