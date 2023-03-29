
output "subnets" {
  #value = aws_subnet.subnets
  value = [for subnet in aws_subnet.subnets : {
    id     = subnet.id
    az     = subnet.availability_zone
    cidr   = subnet.cidr_block
    vpc_id = subnet.vpc_id
  }]
}
