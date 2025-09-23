

resource "aws_route53_record" "alias" {

  zone_id = var.zone_id
  name    = var.record_name
  type    = var.record_type

  alias {
    name    = var.target_name
    zone_id = var.zone_id

    evaluate_target_health = false
  }
}
