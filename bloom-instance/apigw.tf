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
resource "aws_api_gateway_resource" "global" {
  parent_id   = aws_api_gateway_rest_api.internal_api.root_resource_id
  path_part   = "/{proxy+}"
  rest_api_id = aws_api_gateway_rest_api.internal_api.id

}
resource "aws_api_gateway_method" "name" {
  rest_api_id   = aws_api_gateway_rest_api.internal_api.id
  resource_id   = aws_api_gateway_resource.global.id
  http_method   = "ANY"
  authorization = "NONE"


}

resource "aws_api_gateway_integration" "name" {
  http_method = "ANY"
  rest_api_id = aws_api_gateway_rest_api.internal_api.id
  resource_id = aws_api_gateway_resource.global.id
  type        = "HTTP_PROXY"
  uri         = "https://backend.dev.housingbayarea.mtc.ca.gov"
}
