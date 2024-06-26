provider "aws" {
  region = "us-east-1"
  alias  = "use1"

}
resource "aws_wafv2_web_acl" "cloudfront_acl" {
  name        = "${local.qualified_name_prefix}-cloudfront-acl"
  description = "ACL for the cloudfront distribution"
  scope       = "CLOUDFRONT"

  default_action {
    allow {}
  }

  dynamic "rule" {
    for_each = local.global_managed_waf_rules
    content {
      name     = rule.value
      priority = index(local.global_managed_waf_rules, rule.value)

      override_action {
        count {}
      }

      statement {
        managed_rule_group_statement {
          name        = rule.value
          vendor_name = "AWS"

          scope_down_statement {
            geo_match_statement {
              country_codes = ["US"]
            }
          }
        }


      }
      visibility_config {
        cloudwatch_metrics_enabled = true
        metric_name                = "${local.qualified_name_prefix}-${rule.value}_ruleset_cf"
        sampled_requests_enabled   = true
      }

    }




  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "${local.qualified_name_prefix}-cloudfront-acl"
    sampled_requests_enabled   = true
  }
  provider = aws.use1
}

resource "aws_wafv2_web_acl" "apigw_acl" {
  name        = "${local.qualified_name_prefix}-waf-acl"
  description = "ACL for the waf"
  scope       = "REGIONAL"

  default_action {
    allow {}
  }

  dynamic "rule" {
    for_each = local.global_managed_waf_rules
    content {
      name     = rule.value
      priority = index(local.global_managed_waf_rules, rule.value)

      override_action {
        count {}
      }

      statement {
        managed_rule_group_statement {
          name        = rule.value
          vendor_name = "AWS"

          scope_down_statement {
            geo_match_statement {
              country_codes = ["US"]
            }
          }
        }


      }
      visibility_config {
        cloudwatch_metrics_enabled = true
        metric_name                = "${local.qualified_name_prefix}-${rule.value}_ruleset_api"
        sampled_requests_enabled   = true
      }
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "${local.qualified_name_prefix}-api-acl"
    sampled_requests_enabled   = true
  }
  provider = aws
}
resource "aws_wafv2_web_acl_association" "example" {
  resource_arn = aws_api_gateway_stage.main.arn
  web_acl_arn  = aws_wafv2_web_acl.apigw_acl.arn
}
