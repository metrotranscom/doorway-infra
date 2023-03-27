
output "endpoint" {
  value = aws_db_instance.rds[0].endpoint
}
