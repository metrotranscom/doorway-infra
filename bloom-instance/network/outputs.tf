# This file contains values that we want to be accessible outside of this module

output "vpc" {
  value = aws_vpc.vpc
}

output "subnets" {
  value = {
    public = module.public.subnets
    app    = module.app.subnets
    data   = module.data.subnets
  }
}

/*
output "public_subnets" {
  value = module.public.subnets
}

output "app_subnets" {
  value = module.app.subnets
}

output "data_subnets" {
  value = module.data.subnets
}
*/
