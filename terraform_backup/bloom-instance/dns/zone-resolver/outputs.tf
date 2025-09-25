
output "found" {
  value = local.match != null
}

output "name" {
  value = local.match != null ? local.match.name : null
}

output "id" {
  value = local.match != null ? local.match.id : null
}
