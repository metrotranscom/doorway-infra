
output "alb" {
  value = aws_lb.alb
}

output "security_group" {
  value = aws_security_group.alb
}

output "listeners" {
  value = aws_lb_listener.alb_listeners
}
