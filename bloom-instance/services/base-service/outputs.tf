
output "target_group" {
  value = aws_lb_target_group.service
}

output "security_group" {
  value = aws_security_group.service
}

/*
output "public_url" {
  value = ""
}

output "internal_url" {
  value = ""
}
*/
