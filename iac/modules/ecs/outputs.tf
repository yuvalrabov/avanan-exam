output "ecs_cluster_id" {
  value = aws_ecs_cluster.cluster.id
}

output "ecs_service_ids" {
  value = aws_ecs_service.service[*].id
}

output "task_definition_arns" {
  value = aws_ecs_task_definition.task_definition[*].arn
}