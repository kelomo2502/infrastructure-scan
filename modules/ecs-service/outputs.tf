# modules/ecs-service/outputs.tf

output "service_name" {
  description = "Name of the ECS service"
  value       = aws_ecs_service.microservice.name
}

output "task_definition_arn" {
  description = "ARN of the task definition"
  value       = aws_ecs_task_definition.microservice_task.arn
}

output "service_discovery_name" {
  description = "Service discovery name"
  value       = aws_service_discovery_service.microservice.name
}

output "security_group_id" {
  description = "Security group ID for the service"
  value       = aws_security_group.microservice_sg.id
}