resource "aws_codestarnotifications_notification_rule" "rule" {
  detail_type    = var.detail
  event_type_ids = var.events

  name     = "${var.name_prefix}-notify-${var.name}"
  resource = var.resource_arn

  target {
    address = var.topic_arn
  }
}
