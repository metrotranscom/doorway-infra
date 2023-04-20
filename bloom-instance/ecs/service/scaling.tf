
/*
resource "aws_appautoscaling_target" "service" {
  resource_id = "service/${aws_ecs_cluster.service.name}/${aws_ecs_service.service.name}"

  min_capacity = var.min_count
  max_capacity = var.max_count

  service_namespace  = "ecs"
  scalable_dimension = "ecs:service:DesiredCount"
}

/*
resource "aws"appautoscaling_policy" "ecs_policy" {

}
*/
