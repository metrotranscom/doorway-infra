
output "address" {
  value = local.is_rds ? aws_db_instance.rds[0].address : aws_rds_cluster.aurora[0].address
}

output "port" {
  value = local.is_rds ? aws_db_instance.rds[0].port : aws_rds_cluster.aurora[0].port
}

output "username" {
  value = local.is_rds ? aws_db_instance.rds[0].username : aws_rds_cluster.aurora[0].username
}
