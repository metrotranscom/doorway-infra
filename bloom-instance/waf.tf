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

  rule {
    name     = "common-rule-set"
    priority = 1

    override_action {
      count {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesCommonRuleSet"
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
      metric_name                = "${local.qualified_name_prefix}-cloudfront-acl-common_ruleset"
      sampled_requests_enabled   = true
    }
  }

  tags = {
    Tag1 = "Value1"
    Tag2 = "Value2"
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "${local.qualified_name_prefix}-cloudfront-acl"
    sampled_requests_enabled   = true
  }
  provider = aws.use1
}

