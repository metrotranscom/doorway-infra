
output "alb" {
  value = aws_lb.alb
}

# Used by services to allow the ALB to forward requests
output "security_group" {
  value = aws_security_group.alb
}

output "listeners" {
  #value = aws_lb_listener.alb_listeners
  value = module.listeners
}

# Used for generating log bucket policy
output "log_prefix" {
  value = var.enable_logging ? local.log_prefix : ""
}

output "dns_name" {
  value = aws_lb.alb.dns_name
}
