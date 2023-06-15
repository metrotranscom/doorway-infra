
output "label" {
  value = var.label
}

output "build_actions" {
  value = local.build_actions_out
}

output "approval_actions" {
  value = local.approval_actions_out
}
