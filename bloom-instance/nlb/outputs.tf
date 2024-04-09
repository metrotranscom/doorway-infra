
output "nlb" {
  value = aws_lb.nlb
}

output "arn" {
  value = aws_lb.nlb.arn
}

# Used by services to allow the NLB to forward requests
output "security_group" {
  value = {
    id = aws_security_group.nlb.id
  }
}

output "listeners" {
  #value = aws_lb_listener.nlb_listeners
  value = module.listeners
}

# Used for generating log bucket policy
output "log_prefix" {
  value = local.log_prefix
}

output "dns_name" {
  value = aws_lb.nlb.dns_name
}

output "zone_id" {
  value = aws_lb.nlb.zone_id
}
