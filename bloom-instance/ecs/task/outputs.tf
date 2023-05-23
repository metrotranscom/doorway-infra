
output "arn" {
  value = aws_ecs_task_definition.task.arn
}

output "id" {
  value = aws_ecs_task_definition.task.id
}

output "exec_role_arn" {
  value = aws_iam_role.task_exec.arn
}
