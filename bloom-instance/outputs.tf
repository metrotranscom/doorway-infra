
output "cert_validation_records_not_created" {
  value = { for key, cert in module.certs : key => cert.unmatched_validation_records }
}

output "urls" {
  value = {
    public   = var.public_portal_domain
    partners = var.partners_portal_domain
    backend  = var.backend_api_domain
  }
}

output "network" {
  value = {
    vpc_id = module.network.vpc.id
    subnets = {
      for name, subnet_group in module.network.subnets : name => [
        for subnet in subnet_group : subnet.id
      ]
    }
  }
}

output "default_cluster_name" {
  value = aws_ecs_cluster.default.name
}
output "default_cluster_arn" {
  value = aws_ecs_cluster.default.arn
}
