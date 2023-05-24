
output "arn" {
  value = aws_lb_listener.listener.arn
}

output "port" {
  value = local.port
}

output "is_secure" {
  value = local.use_tls
}
