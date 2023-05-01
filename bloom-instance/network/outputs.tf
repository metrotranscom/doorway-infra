
output "vpc" {
  value = aws_vpc.vpc
}

# a list of just the public subnets
output "public_subnets" {
  value = module.public_subnet_group.subnets
}

# a map of all subnets indexed by subnet group id (including public)
output "subnets" {
  value = merge(
    { for id, group in module.private_subnet_groups : id => group.subnets },
    {
      "${local.public_subnet_group_id}" : module.public_subnet_group.subnets
    }
  )
}
