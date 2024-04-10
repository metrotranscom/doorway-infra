resource "aws_vpc_endpoint" "api_endpoint" {
  vpc_id              = module.network.vpc.id
  service_name        = "com.amazonaws.${local.aws_region}.execute-api"
  vpc_endpoint_type   = "Interface"
  security_group_ids  = [module.nlbs["api-nlb"].security_group.id]
  private_dns_enabled = true
  subnet_ids          = [for subnet in module.network.app_subnets : subnet.id]


}
resource "aws_api_gateway_rest_api" "internal_api" {
  name = "${local.qualified_name_prefix}-internal"
  endpoint_configuration {
    types            = ["PRIVATE"]
    vpc_endpoint_ids = [aws_vpc_endpoint.api_endpoint.id]

  }



}
