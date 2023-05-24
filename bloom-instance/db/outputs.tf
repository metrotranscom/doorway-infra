
output "host" {
  value = local.db.host
}

output "port" {
  value = local.db.port
}

output "username" {
  value = local.db.username
}

output "db_name" {
  value = local.db.db_name
}

output "secret_arn" {
  value = aws_secretsmanager_secret.conn_string.arn
}

output "security_group_id" {
  value = aws_security_group.db.id
}

output "connection_string" {
  value = local.conn_string
}

