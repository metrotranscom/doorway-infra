
output "arn" {
  value = aws_lb_listener.listener.arn
}

output "port" {
  value = 443
}

output "is_secure" {
  value = true
}
