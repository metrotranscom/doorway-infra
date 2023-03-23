
locals {
  /*
  # Convert listeners[name].allowed_ips to a flat list of tuples for ingress rules
  port_mappings = flatten([
    for k, v in var.listeners : [
      for i, ip in v.allowed_ips : {
        name = k
        port = v.port
        cidr = ip
      }
    ]
  ])
  */

  # The prefix to prepend to log entries for this ALB
  log_prefix = "${var.name_prefix}/alb/${var.name}"
}
