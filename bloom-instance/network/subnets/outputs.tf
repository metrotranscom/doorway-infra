
output "subnets" {
  #value = aws_subnet.subnets
  value = [for subnet in aws_subnet.subnets : {
    id  = subnet.id
    az  = subnet.availability_zone
    ips = subnet.cidr_block
  }]
}
