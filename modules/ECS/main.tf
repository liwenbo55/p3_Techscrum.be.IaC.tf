##########################################################################
# ECS cluster
##########################################################################
resource "aws_ecs_cluster" "backend_ecs" {
  name = "${var.project_name}-ecs-cluster-${var.environment}"
  setting {
    name  = var.ecs_cluster_setting_name
    value = var.ecs_cluster_setting_value
  }
}

resource "aws_ecs_cluster_capacity_providers" "providers" {
  cluster_name = aws_ecs_cluster.backend_ecs.name

  capacity_providers = var.ecs_cluster_capacity_providers
  #   default_capacity_provider_strategy {
  #     capacity_provider = "FARGATE"
  #   }
}

##########################################################################
# task definition
##########################################################################
resource "aws_ecs_task_definition" "ecs_task" {
  family                   = "${var.project_name}-ecs-task-definition-${var.environment}"
  network_mode             = var.task_definition_network_mode
  cpu                      = var.task_definition_fargate_cpu
  memory                   = var.task_definition_fargate_memory
  requires_compatibilities = var.task_definition_launch_type
  execution_role_arn       = var.task_definition_execution_role_arn
  task_role_arn            = var.task_definition_execution_role_arn

  container_definitions = jsonencode([
    {
      "name" : "${var.project_name}-backend-container-${var.environment}",
      "image" : "${var.container_image}:latest",
      "essential" : var.container_essential,
      "portMappings" : [
        {
          "containerPort" : var.container_portMappings_containerPort,
          "hostPort" : var.container_portMappings_hostPort,
          "protocol" : var.container_portMappings_protocol
        }
      ],
      "healthCheck" : {
        "command" : [
          "CMD-SHELL",
          "curl -f http://localhost:8000/api/v2/healthcheck || exit 1"
        ],
        "interval" : 30,
        "timeout" : 5,
        "retries" : 3,
        "startPeriod" : 0
      },
      "logConfiguration" : {
        "logDriver" : "awslogs",
        "options" : {
          "awslogs-group" : "${var.project_name}-backend-ecs-container-${var.environment}",
          "awslogs-region" : "ap-southeast-2",
          "awslogs-create-group" : "true",
          "awslogs-stream-prefix" : "ecs"
        }
      },
      "environment" : [
        { "name" : "ENVIRONMENT", "value" : "${data.aws_ssm_parameter.environment.value}" },
        { "name" : "NAME", "value" : "${data.aws_ssm_parameter.name.value}" },
        { "name" : "PORT", "value" : "${data.aws_ssm_parameter.port.value}" },
        { "name" : "API_PREFIX", "value" : "${data.aws_ssm_parameter.api_prefix.value}" },
        { "name" : "AWS_REGION", "value" : "${data.aws_ssm_parameter.region.value}" },
        { "name" : "ACCESS_SECRET", "value" : "${data.aws_ssm_parameter.access_secret.value}" },
        { "name" : "EMAIL_SECRET", "value" : "${data.aws_ssm_parameter.email_secret.value}" },
        { "name" : "FORGET_SECRET", "value" : "${data.aws_ssm_parameter.forget_secret.value}" },
        { "name" : "LIMITER", "value" : "${data.aws_ssm_parameter.limiter.value}" },
        { "name" : "MAIN_DOMAIN", "value" : "${data.aws_ssm_parameter.main_domain.value}" },
        { "name" : "STRIPE_PRIVATE_KEY", "value" : "${data.aws_ssm_parameter.stripe_private_key.value}" },
        { "name" : "STRIPE_WEBHOOK_SECRET", "value" : "${data.aws_ssm_parameter.stripe_webhook_secret.value}" },
        { "name" : "DEVOPS_MODE", "value" : "${data.aws_ssm_parameter.devops_mode.value}" }
      ],
      "secrets" : [
        { "name" : "AWS_SECRET_ACCESS_KEY", "valueFrom" : "${data.aws_ssm_parameter.secret_access_key.arn}" },
        { "name" : "AWS_ACCESS_KEY_ID", "valueFrom" : "${data.aws_ssm_parameter.access_key_id.arn}" },
        { "name" : "PUBLIC_CONNECTION", "valueFrom" : "${data.aws_ssm_parameter.public_connection.arn}" },
        { "name" : "TENANTS_CONNECTION", "valueFrom" : "${data.aws_ssm_parameter.tenants_connection.arn}" }
      ]
    }
  ])

  runtime_platform {
    operating_system_family = var.task_definition_runtime_platform_system
    cpu_architecture        = var.task_definition_runtime_cpu_architecture
  }

  tags = {
    Environment = var.environment
  }
}

##########################################################################
# ECS service
##########################################################################
resource "aws_ecs_service" "ecs_service" {
  launch_type                       = var.ecs_service_launch_type
  task_definition                   = aws_ecs_task_definition.ecs_task.arn
  platform_version                  = var.ecs_service_platform_version
  cluster                           = aws_ecs_cluster.backend_ecs.arn
  name                              = "${var.project_name}-ecs-service-${var.environment}"
  desired_count                     = var.ecs_service_desired_tasks
  force_new_deployment              = var.ecs_service_force_new_deployment
  health_check_grace_period_seconds = 30

  network_configuration {
    security_groups  = var.ecs_service_network_security_groups
    subnets          = var.ecs_service_vpc_subnets
    assign_public_ip = var.ecs_service_network_assign_public_ip
  }

  load_balancer {
    target_group_arn = var.ecs_service_target_group_arn
    container_name   = "${var.project_name}-backend-container-${var.environment}"
    container_port   = var.container_portMappings_containerPort
  }

  #   lifecycle {
  #     ignore_changes = [desired_count]
  #   }
  tags = {
    Environment = var.environment
  }

}
##########################################################################
# Cloudwatch for container log
##########################################################################
resource "aws_cloudwatch_log_group" "ecs_container_log_group" {
  name = "${var.project_name}-backend-ecs-container-${var.environment}"

  tags = {
    Environment = "${var.environment}"
    Application = "${var.project_name}"
  }
}

# resource "aws_cloudwatch_log_stream" "ecs_container_log_stream" {
#   name           = "${var.project_name}-log_stream-${var.environment}"
#   log_group_name = aws_cloudwatch_log_group.ecs_container_log_group.name
# }

##########################################################################
# Autoscalling
##########################################################################
resource "aws_appautoscaling_target" "ecs_target" {
  service_namespace  = var.ecs_autoscaling_service_namespace
  max_capacity       = var.ecs_autoscaling_max_capacity
  min_capacity       = var.ecs_autoscaling_min_capacity
  resource_id        = "service/${aws_ecs_cluster.backend_ecs.name}/${aws_ecs_service.ecs_service.name}"
  scalable_dimension = var.ecs_autoscaling_scalable_dimension
}

# Scale up and scale down policy (for +1/-1 task)
resource "aws_appautoscaling_policy" "scale_up_policy" {
  name               = "${var.project_name}-ecs-scale-up-policy-${var.environment}"
  resource_id        = aws_appautoscaling_target.ecs_target.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_target.scalable_dimension
  service_namespace  = aws_appautoscaling_target.ecs_target.service_namespace


  step_scaling_policy_configuration {
    adjustment_type         = "ChangeInCapacity"
    cooldown                = 60
    metric_aggregation_type = "Maximum"

    step_adjustment {
      metric_interval_lower_bound = 0
      scaling_adjustment          = 1
    }
  }
}

resource "aws_appautoscaling_policy" "scale_down_policy" {
  name               = "${var.project_name}-ecs-scale-down-policy-${var.environment}"
  resource_id        = aws_appautoscaling_target.ecs_target.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_target.scalable_dimension
  service_namespace  = aws_appautoscaling_target.ecs_target.service_namespace

  step_scaling_policy_configuration {
    adjustment_type         = "ChangeInCapacity"
    cooldown                = 60
    metric_aggregation_type = "Maximum"

    step_adjustment {
      metric_interval_upper_bound = 0
      scaling_adjustment          = -1
    }
  }
}
##########################################################################
# Create two alarms and alarm actions.
##########################################################################
# Alarms are used to trigger autoscaling polices.
resource "aws_cloudwatch_metric_alarm" "cpu_high" {
  alarm_name          = "${var.project_name}-ecs-service-cpu-high-alarm-${var.environment}"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "5"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = "60"
  statistic           = "Maximum"
  threshold           = "80"
  # threshold           = "0.1"
  alarm_actions = [aws_appautoscaling_policy.scale_up_policy.arn]

  dimensions = {
    ClusterName = aws_ecs_cluster.backend_ecs.name
    ServiceName = aws_ecs_service.ecs_service.name
  }
}

resource "aws_cloudwatch_metric_alarm" "cpu_low" {
  alarm_name          = "${var.project_name}-ecs-service-cpu-low-alarm-${var.environment}"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = "5"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = "60"
  statistic           = "Average"
  threshold           = "10"
  alarm_actions       = [aws_appautoscaling_policy.scale_down_policy.arn]

  dimensions = {
    ClusterName = aws_ecs_cluster.backend_ecs.name
    ServiceName = aws_ecs_service.ecs_service.name
  }
}
