resource "aws_vpc_endpoint" "api_endpoint" {
  vpc_id              = module.network.vpc.id
  service_name        = "com.amazonaws.${local.aws_region}.execute-api"
  vpc_endpoint_type   = "Interface"
  security_group_ids  = [module.nlbs["api-nlb"].security_group.id]
  private_dns_enabled = true



}