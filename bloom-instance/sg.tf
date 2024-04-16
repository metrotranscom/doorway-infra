resource "aws_security_group" "local_https_only" {
  name        = "local_https"
  description = "Allow TLS inbound traffic and all outbound traffic"
  vpc_id      = module.network.vpc.id

  tags = {
    Name = "local_https"
  }
}
# Create ingress rules for each set of allowed CIDR blocks
resource "aws_vpc_security_group_ingress_rule" "local_https_ingress" {
  for_each = { for cidr in local.local_cidrs : cidr => cidr }

  security_group_id = aws_security_group.local_https_only.id

  cidr_ipv4   = each.value
  from_port   = 443
  to_port     = 443
  ip_protocol = "TCP"


}
# Create ingress rules for each set of allowed CIDR blocks
resource "aws_vpc_security_group_egress_rule" "local_https_egress" {
  security_group_id = aws_security_group.local_https_only.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"

}

resource "aws_security_group" "ecs_sg" {
  name        = "ecs_sg"
  description = "Allow TLS inbound traffic and all outbound traffic"
  vpc_id      = module.network.vpc.id

  tags = {
    Name = "ecs_sg"
  }
}
# Create ingress rules for each set of allowed CIDR blocks
resource "aws_vpc_security_group_egress_rule" "ecs_egress" {
  security_group_id = aws_security_group.ecs_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"

}
