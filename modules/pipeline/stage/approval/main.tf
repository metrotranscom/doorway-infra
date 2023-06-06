
resource "aws_sns_topic" "topic" {
  name = "${var.name_prefix}-approval-${var.name}"
}

resource "aws_sns_topic_subscription" "emails" {
  for_each  = var.emails
  topic_arn = aws_sns_topic.topic.arn
  protocol  = "email"
  endpoint  = each.value
}
