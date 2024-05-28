# Define the ECS service to be scaled with specified minimum and maximum capacities
resource "aws_appautoscaling_target" "target" {
  service_namespace  = "ecs"                                                               # The namespace for ECS services
  resource_id        = "service/${aws_ecs_cluster.main.name}/${aws_ecs_service.main.name}" # The ECS service to be scaled
  scalable_dimension = "ecs:service:DesiredCount"                                          # The attribute to be scaled (number of desired tasks)
  role_arn           = aws_iam_role.ecs_auto_scale_role.arn                                # The IAM role that allows Application Auto Scaling to manage the ECS service
  min_capacity       = 3                                                                   # Minimum number of tasks
  max_capacity       = 6                                                                   # Maximum number of tasks
}

# Define the policy to scale up the ECS service
resource "aws_appautoscaling_policy" "up" {
  name               = "app-hello-scale-up"                                                # Name of the scaling policy
  service_namespace  = "ecs"                                                               # The namespace for ECS services
  resource_id        = "service/${aws_ecs_cluster.main.name}/${aws_ecs_service.main.name}" # The ECS service to be scaled
  scalable_dimension = "ecs:service:DesiredCount"                                          # The attribute to be scaled (number of desired tasks)

  step_scaling_policy_configuration {
    adjustment_type         = "ChangeInCapacity" # Type of adjustment (change in number of tasks)
    cooldown                = 60                 # Cooldown period in seconds between scaling actions
    metric_aggregation_type = "Maximum"          # Aggregation type for the scaling metric

    step_adjustment {
      metric_interval_lower_bound = 0 # Lower bound for the scaling metric
      scaling_adjustment          = 1 # Number of tasks to add when the policy is triggered
    }
  }

  depends_on = [aws_appautoscaling_target.target] # Ensure the scaling target is created first
}
# Define the policy to scale down the ECS service
resource "aws_appautoscaling_policy" "down" {
  name               = "app-hello-scale-down"                                              # Name of the scaling policy
  service_namespace  = "ecs"                                                               # The namespace for ECS services
  resource_id        = "service/${aws_ecs_cluster.main.name}/${aws_ecs_service.main.name}" # The ECS service to be scaled
  scalable_dimension = "ecs:service:DesiredCount"                                          # The attribute to be scaled (number of desired tasks)

  step_scaling_policy_configuration {
    adjustment_type         = "ChangeInCapacity" # Type of adjustment (change in number of tasks)
    cooldown                = 60                 # Cooldown period in seconds between scaling actions
    metric_aggregation_type = "Maximum"          # Aggregation type for the scaling metric

    step_adjustment {
      metric_interval_lower_bound = 0  # Lower bound for the scaling metric
      scaling_adjustment          = -1 # Number of tasks to remove when the policy is triggered
    }
  }

  depends_on = [aws_appautoscaling_target.target] # Ensure the scaling target is created first
}

# CloudWatch alarm that triggers the autoscaling up policy
# Define a CloudWatch alarm to trigger the scaling up policy based on high CPU utilization
resource "aws_cloudwatch_metric_alarm" "service_cpu_high" {
  alarm_name          = "app-hello-cpu-utilization-high" # Name of the alarm
  comparison_operator = "GreaterThanOrEqualToThreshold"  # Condition to trigger the alarm
  evaluation_periods  = "2"                              # Number of periods to evaluate
  metric_name         = "CPUUtilization"                 # The metric to monitor
  namespace           = "AWS/ECS"                        # The namespace of the metric
  period              = "60"                             # Period in seconds for each evaluation
  statistic           = "Average"                        # Statistic to use for the metric
  threshold           = "85"                             # Threshold to trigger the alarm

  dimensions = {
    ClusterName = aws_ecs_cluster.main.name # ECS cluster name
    ServiceName = aws_ecs_service.main.name # ECS service name
  }

  alarm_actions = [aws_appautoscaling_policy.up.arn] # Action to trigger when the alarm goes off
}


# Define a CloudWatch alarm to trigger the scaling down policy based on low CPU utilization
resource "aws_cloudwatch_metric_alarm" "service_cpu_low" {
  alarm_name          = "app-hello-cpu-utilization-low" # Name of the alarm
  comparison_operator = "LessThanOrEqualToThreshold"    # Condition to trigger the alarm
  evaluation_periods  = "2"                             # Number of periods to evaluate
  metric_name         = "CPUUtilization"                # The metric to monitor
  namespace           = "AWS/ECS"                       # The namespace of the metric
  period              = "60"                            # Period in seconds for each evaluation
  statistic           = "Average"                       # Statistic to use for the metric
  threshold           = "10"                            # Threshold to trigger the alarm

  dimensions = {
    ClusterName = aws_ecs_cluster.main.name # ECS cluster name
    ServiceName = aws_ecs_service.main.name # ECS service name
  }

  alarm_actions = [aws_appautoscaling_policy.down.arn] # Action to trigger when the alarm goes off
}
