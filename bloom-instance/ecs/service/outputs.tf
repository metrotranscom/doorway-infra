
output "target_group" {
  value = aws_lb_target_group.service
}

output "security_group" {
  value = aws_security_group.service
}

# output "urls_by_listener" {
#   value = local.urls_by_listener
# }

# output "url_list" {
#   value = local.url_list
# }

/*
output "public_url" {
  value = ""
}

output "internal_url" {
  value = ""
}
*/
