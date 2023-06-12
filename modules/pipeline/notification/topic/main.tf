
resource "aws_sns_topic" "topic" {
  name = "${var.name_prefix}-notify-${var.name}"
}

resource "aws_sns_topic_subscription" "emails" {
  for_each  = var.emails
  topic_arn = aws_sns_topic.topic.arn
  protocol  = "email"
  endpoint  = each.value
}

resource "aws_sns_topic_policy" "allow_codestar" {
  arn = aws_sns_topic.topic.arn

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = {
      Sid    = "AllowCodeStarNotifications"
      Action = ["sns:Publish"]
      Effect = "Allow"
      Principal = {
        Service = "codestar-notifications.amazonaws.com"
      }
      Resource = aws_sns_topic.topic.arn,
    }
  })
}
