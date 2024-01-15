output "ecs_cluster_name" {
  value = aws_ecs_cluster.backend_ecs.name
}

output "ecs_service_name" {
  value = aws_ecs_service.ecs_service.name
}

