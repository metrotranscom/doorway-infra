

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
resource "aws_api_gateway_method" "method" {
  rest_api_id   = aws_api_gateway_rest_api.apigw.id
  resource_id   = aws_api_gateway_resource.global.id
  http_method   = "ANY"
  authorization = "NONE"
  request_parameters = {
    "method.request.path.proxy"              = true
    "method.request.header.jurisdictionName" = true
    "method.request.header.Host"             = true
    "method.request.header.appUrl"           = true
  }
}
resource "aws_api_gateway_method_settings" "method_settings" {
  method_path = "*/*"
  rest_api_id = aws_api_gateway_rest_api.apigw.id
  stage_name  = aws_api_gateway_stage.main.stage_name

  settings {
    logging_level      = "INFO"
    metrics_enabled    = true
    data_trace_enabled = true

  }

}


resource "aws_api_gateway_integration" "global_integration" {
  rest_api_id = aws_api_gateway_rest_api.apigw.id
  resource_id = aws_api_gateway_resource.global.id

  type                    = "HTTP_PROXY"
  uri                     = "https://${aws_api_gateway_domain_name.apigw.domain_name}/{proxy}"
  http_method             = "ANY"
  integration_http_method = "ANY"
  connection_type         = "VPC_LINK"
  connection_id           = aws_api_gateway_vpc_link.vpclink.id
  request_parameters = {
    "integration.request.path.proxy"              = "method.request.path.proxy"
    "integration.request.header.jurisdictionName" = "method.request.header.jurisdictionName"
    "integration.request.header.Host"             = "method.request.header.Host"
  }

}


resource "aws_api_gateway_deployment" "deployment" {

  rest_api_id = aws_api_gateway_rest_api.apigw.id
  #TODO: This auto-deploy code still has issues. hoping to get it fixed soon.
  triggers = {
    # NOTE: The configuration below will satisfy ordering considerations,
    #       but not pick up all future REST API changes. More advanced patterns
    #       are possible, such as using the filesha1() function against the
    #       Terraform configuration file(s) or removing the .id references to
    #       calculate a hash against whole resources. Be aware that using whole
    #       resources will show a difference after the initial implementation.
    #       It will stabilize to only change when resources change afterwards.
    redeployment = sha1(jsonencode([

      aws_api_gateway_resource.global.id,
      aws_api_gateway_method.method.id,
      aws_api_gateway_integration.global_integration.id
    ]))
  }
}
resource "aws_api_gateway_stage" "main" {
  deployment_id = aws_api_gateway_deployment.deployment.id
  rest_api_id   = aws_api_gateway_rest_api.apigw.id
  stage_name    = "main"
}
resource "aws_api_gateway_base_path_mapping" "mapping" {
  api_id      = aws_api_gateway_rest_api.apigw.id
  domain_name = aws_api_gateway_domain_name.apigw.domain_name
  stage_name  = aws_api_gateway_stage.main.stage_name

}
