
resource "aws_appautoscaling_target" "service" {
  count       = local.use_scaling ? 1 : 0
  resource_id = "service/${local.cluster_name}/${aws_ecs_service.service.name}"

  min_capacity = local.scaling.min
  max_capacity = local.scaling.max

  service_namespace  = "ecs"
  scalable_dimension = "ecs:service:DesiredCount"
}

resource "aws_appautoscaling_policy" "ecs_policy" {
  for_each           = local.autoscaling_metrics
  name               = "${local.default_name}-scaling-policy-${each.key}"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.service[0].resource_id
  scalable_dimension = aws_appautoscaling_target.service[0].scalable_dimension
  service_namespace  = aws_appautoscaling_target.service[0].service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = each.value.name
    }
    target_value = each.value.target
  }
  depends_on = [aws_appautoscaling_target.service]
}
