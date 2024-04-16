resource "aws_security_group" "local_https_only" {
  name        = "${local.qualified_name_prefix}_local_https"
  description = "Allow TLS inbound traffic and all outbound traffic"
  vpc_id      = module.network.vpc.id

  tags = {
    Name = "${local.qualified_name_prefix}_local_https"
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
  name        = "${local.qualified_name_prefix}__ecs_sg"
  description = "Allow TLS inbound traffic and all outbound traffic"
  vpc_id      = module.network.vpc.id

  tags = {
    Name = "${local.qualified_name_prefix}__ecs_sg"
  }
}

# Create ingress rules for each set of allowed CIDR blocks
resource "aws_vpc_security_group_ingress_rule" "local_ecs_public_service_ingress" {
  for_each = { for cidr in local.local_cidrs : cidr => cidr }

  security_group_id = aws_security_group.ecs_sg.id

  cidr_ipv4   = each.value
  from_port   = var.public_sites[0].port
  to_port     = var.public_sites[0].port
  ip_protocol = "TCP"


}
# Create ingress rules for each set of allowed CIDR blocks
resource "aws_vpc_security_group_ingress_rule" "local_ecs__partners_service_ingress" {
  for_each = { for cidr in local.local_cidrs : cidr => cidr }

  security_group_id = aws_security_group.ecs_sg.id

  cidr_ipv4   = each.value
  from_port   = var.partner_site.port
  to_port     = var.partner_site.port
  ip_protocol = "TCP"


}
# Create ingress rules for each set of allowed CIDR blocks
resource "aws_vpc_security_group_ingress_rule" "local_ecs_api_service_ingress" {
  for_each = { for cidr in local.local_cidrs : cidr => cidr }

  security_group_id = aws_security_group.ecs_sg.id

  cidr_ipv4   = each.value
  from_port   = var.backend_api.port
  to_port     = var.backend_api.port
  ip_protocol = "TCP"


}
# Create ingress rules for each set of allowed CIDR blocks
resource "aws_vpc_security_group_egress_rule" "ecs_egress" {
  security_group_id = aws_security_group.ecs_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"

}
resource "aws_security_group" "db_sg" {
  name        = "${local.qualified_name_prefix}__db_sg"
  description = "Allow TLS inbound traffic and all outbound traffic"
  vpc_id      = module.network.vpc.id

  tags = {
    Name = "${local.qualified_name_prefix}__db_sg"
  }
}
# Create ingress rules for each set of allowed CIDR blocks
resource "aws_vpc_security_group_egress_rule" "ecs_egress" {
  security_group_id = aws_security_group.ecs_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"

}
