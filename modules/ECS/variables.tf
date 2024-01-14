variable "project_name" {
  description = "The project name."
  type        = string
}
variable "environment" {
  description = "The environment name."
  type        = string
}

variable "ecs_cluster_setting_name" {
  description = "Name of the setting to manage. Valid values: containerInsights."
  type        = string
  default     = "containerInsights"
}
variable "ecs_cluster_setting_value" {
  description = "The value to assign to the setting. Valid values are enabled and disabled. Default to enabled."
  type        = string
  default     = "enabled"
}

# task definition
variable "ecs_cluster_capacity_providers" {
  description = "Set of names of one or more capacity providers to associate with the cluster. Valid values also include FARGATE and FARGATE_SPOT."
  type        = list(string)
  default     = ["FARGATE", "FARGATE_SPOT"]
}

variable "task_definition_network_mode" {
  description = "Docker networking mode to use for the containers in the task. Valid values are none, bridge, awsvpc, and host. Set to awsvpc by default."
  type        = string
  default     = "awsvpc"
}

variable "task_definition_fargate_cpu" {
  description = "Number of cpu units used by the task. Default to 1024 for 1 vCPU."
  type        = number
  default     = 1024
}

variable "task_definition_fargate_memory" {
  description = "Amount (in MiB) of memory used by the task. Default to 2048 for 2GB."
  type        = number
  default     = 2048
}
variable "task_definition_launch_type" {
  description = "Set of launch types required by the task. The valid values are EC2 and FARGATE."
  type        = list(string)
  default     = ["FARGATE"]
}
variable "task_definition_runtime_platform_system" {
  description = "This parameter is required for Amazon ECS tasks that are hosted on Fargate. Set to LINUX by default."
  type        = string
  default     = "LINUX"
}
variable "task_definition_runtime_cpu_architecture" {
  description = "This parameter is required for Amazon ECS tasks hosted on Fargate. Set to X86_64 by default."
  type        = string
  default     = "X86_64"
}

variable "task_definition_execution_role_arn" {
  description = "ARN of the task execution role that the Amazon ECS container agent and the Docker daemon can assume."
  type        = string
}

# task definition - container
variable "container_image" {
  description = "The image used to start a container."
  type        = string
}
variable "container_essential" {
  description = "If the essential parameter of a container is marked as true, and that container fails or stops for any reason, all other containers that are part of the task are stopped. Set to true by default."
  type        = bool
  default     = true
}

variable "container_portMappings_containerPort" {
  description = "The port number on the container that's bound to the user-specified assigned port. Set to 8000 for Techscrum project."
  type        = number
  default     = 8000
}

variable "container_portMappings_hostPort" {
  description = "The port number on the container instance to reserve for container. If using containers in a task with the Fargate launch type, the hostPort can either be kept blank or be the same value as containerPort. Set to 8000 for Techscrum project."
  type        = number
  default     = 8000
}

variable "container_portMappings_protocol" {
  description = "The protocol that's used for the port mapping. Valid values are tcp and udp. Default to tcp."
  type        = string
  default     = "tcp"
}


# ECS service
variable "ecs_service_launch_type" {
  description = "Launch type on which to run the service. Default to FARGATE in this project."
  type        = string
  default     = "FARGATE"
}
variable "ecs_service_platform_version" {
  description = "Platform version on which to run your service. Defaults to LATEST."
  type        = string
  default     = "LATEST"
}
variable "ecs_service_desired_tasks" {
  description = "Number of instances of the task definition to place and keep running. Default to 2."
  type        = number
  default     = 2
}
variable "ecs_service_force_new_deployment" {
  description = "Enable to force a new task deployment of the service. This can be used to update tasks to use a newer Docker image with same image/tag combination (e.g., myimage:latest)."
  type        = bool
  default     = true
}

# ECS service - network configuration
variable "ecs_service_network_security_groups" {
  description = "Security groups associated with the service."
  type        = list(string)
}
variable "ecs_service_vpc_subnets" {
  description = "Subnets associated with the service."
  type        = list(string)
}
variable "ecs_service_network_assign_public_ip" {
  description = "Assign a public IP address to the ENI (Fargate launch type only). Valid values are true or false. Default to True."
  type        = bool
  default     = true
}

# ECS service - load balancer
variable "ecs_service_target_group_arn" {
  description = "ARN of the Load Balancer target group to associate with the service."
  type        = string
}

# Autoscalling
variable "ecs_autoscaling_service_namespace" {
  description = "The AWS service namespace of the scalable target."
  type        = string
  default     = "ecs"
}

variable "ecs_autoscaling_max_capacity" {
  description = "The max capacity of the scalable target. Default to 4."
  type        = number
  default     = 4
}

variable "ecs_autoscaling_min_capacity" {
  description = "The min capacity of the scalable target. Default to 2."
  type        = number
  default     = 2
}

variable "ecs_autoscaling_scalable_dimension" {
  description = "The scalable dimension associated with the scalable target. This string consists of the service namespace, resource type, and scaling property."
  type        = string
  default     = "ecs:service:DesiredCount"
}


