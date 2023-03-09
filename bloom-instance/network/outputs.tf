
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
