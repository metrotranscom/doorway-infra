
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
