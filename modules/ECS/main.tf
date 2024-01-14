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

  container_definitions = jsonencode([
  {
    "name"        : "${var.project_name}-backend-container-${var.environment}",
    "image"       : "${var.container_image}:latest",
    "essential"   : var.container_essential,
    "portMappings": [
      {
        "containerPort": var.container_portMappings_containerPort,
        "hostPort"     : var.container_portMappings_hostPort,
        "protocol"     : var.container_portMappings_protocol
      }
    ],
    "healthCheck" : {
        "command"     : [
          "CMD-SHELL", 
          "curl -f http://localhost:8000/api/v2/healthcheck || exit 1"
          ],
        "interval"    : 30,
        "timeout"     : 5,
        "retries"     : 3,
        "startPeriod" : 0
      },
    "logConfiguration": {
      "logDriver": "awslogs",
      "options"  : {
        "awslogs-group"         : "${var.project_name}-backend-ecs-container-${var.environment}",
        "awslogs-region"        : "ap-southeast-2",
        "awslogs-create-group"  : "true",
        "awslogs-stream-prefix" : "ecs"
      }
    }
  }
])

  # container_definitions = jsonencode([
  #   {
  #     name  = "${var.project_name}-backend-container-${var.environment}"
  #     image = "${var.container_image}:latest"
  #     #   cpu       = var.task_definition_fargate_cpu
  #     #   memory    = var.task_definition_fargate_memory
  #     essential = var.container_essential
  #     portMappings = [
  #       {
  #         containerPort = var.container_portMappings_containerPort
  #         hostPort      = var.container_portMappings_hostPort
  #         protocol      = var.container_portMappings_protocol
  #       }
  #     ],
  #     healthCheck = {
  #         command     = ["CMD-SHELL", "curl -f http://localhost:8000/api/v2/healthcheck || exit 1"]
  #         interval    = 30
  #         timeout     = 5
  #         retries     = 3
  #         startPeriod = 0
  #       },
  #     # "healthCheck": {
  #     # "command": ["CMD-SHELL", "curl -f http://localhost:8000/api/v2/healthcheck || exit 1"],
  #     # "interval": 30,
  #     # "timeout": 5,
  #     # "retries": 3,
  #     # "startPeriod": 0
  #     # },
  #     logConfiguration = {
  #       logDriver = "awslogs"
  #       options = {
  #         "awslogs-group"         = "${var.project_name}-backend-ecs-container-${var.environment}"
  #         "awslogs-region"        = "ap-southeast-2"
  #         "awslogs-create-group"  = "true"
  #         "awslogs-stream-prefix" = "ecs"
  #       }
  #     }
  #   }
  # ])

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
  launch_type          = var.ecs_service_launch_type
  task_definition      = aws_ecs_task_definition.ecs_task.arn
  platform_version     = var.ecs_service_platform_version
  cluster              = aws_ecs_cluster.backend_ecs.arn
  name                 = "${var.project_name}-ecs-service-${var.environment}"
  desired_count        = var.ecs_service_desired_tasks
  force_new_deployment = var.ecs_service_force_new_deployment

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

resource "aws_appautoscaling_policy" "ecs_policy" {
  name               = "ECSAutoScallingPolicy"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.ecs_target.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_target.scalable_dimension
  service_namespace  = aws_appautoscaling_target.ecs_target.service_namespace


  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }

    target_value       = 70
    scale_in_cooldown  = 300
    scale_out_cooldown = 300
  }
}
