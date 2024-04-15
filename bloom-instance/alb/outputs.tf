
output "alb" {
  value = aws_lb.alb
}

output "arn" {
  value = aws_lb.alb.arn
}

# Used by services to allow the ALB to forward requests
output "security_group" {
  value = {
    id = aws_security_group.alb.id
  }
}

# output "listeners" {
#   #value = aws_lb_listener.alb_listeners
#   value = module.listeners
# }

# Used for generating log bucket policy
output "log_prefix" {
  value = local.log_prefix
}

output "dns_name" {
  value = aws_lb.alb.dns_name
}

output "zone_id" {
  value = aws_lb.alb.zone_id
}
