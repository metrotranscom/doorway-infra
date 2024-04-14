data "aws_acm_certificate" "cert" {
  domain = var.public_portal_domain

}
resource "aws_api_gateway_vpc_link" "vpclink" {
  name        = "${local.qualified_name_prefix}-apilink"
  description = "VPC Link for the API"
  target_arns = [module.nlbs["api-nlb"].nlb.arn]
}
resource "aws_api_gateway_rest_api" "apigw" {
  name                         = "${local.qualified_name_prefix}-api"
  disable_execute_api_endpoint = true
  endpoint_configuration {
    types = ["REGIONAL"]

  }




}
resource "aws_api_gateway_domain_name" "apigw" {
  domain_name              = var.backend_api_domain
  regional_certificate_arn = data.aws_acm_certificate.cert.arn
  endpoint_configuration {
    types = ["REGIONAL"]
  }


}
resource "aws_api_gateway_resource" "global" {
  parent_id   = aws_api_gateway_rest_api.apigw.root_resource_id
  path_part   = "{proxy+}"
  rest_api_id = aws_api_gateway_rest_api.apigw.id



}
resource "aws_api_gateway_method" "name" {
  rest_api_id        = aws_api_gateway_rest_api.apigw.id
  resource_id        = aws_api_gateway_resource.global.id
  http_method        = "ANY"
  authorization      = "NONE"
  request_parameters = { "method.request.path.proxy" = true }


}

resource "aws_api_gateway_integration" "global_integration" {
  rest_api_id = aws_api_gateway_rest_api.apigw.id
  resource_id = aws_api_gateway_resource.global.id

  type                    = "HTTP_PROXY"
  uri                     = "${aws_api_gateway_domain_name.apigw.domain_name}/{proxy}"
  http_method             = "ANY"
  integration_http_method = "ANY"
  connection_type         = "VPC_LINK"
  connection_id           = aws_api_gateway_vpc_link.vpclink.id

}
resource "aws_api_gateway_method_response" "good_response" {
  resource_id = aws_api_gateway_resource.global.id
  rest_api_id = aws_api_gateway_rest_api.apigw.id
  http_method = "ANY"
  status_code = 200

}
