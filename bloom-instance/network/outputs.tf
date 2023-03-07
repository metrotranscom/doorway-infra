# This file contains values that we want to be accessible outside of this module

output "vpc" {
  value = aws_vpc.vpc
}

output "public_subnets" {
  value = module.public.subnets
}

output "app_subnets" {
  value = module.app.subnets
}

output "data_subnets" {
  value = module.data.subnets
}
