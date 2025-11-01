# modules/container-registry/outputs.tf

output "ecr_repository_url" {
  description = "The URL of the ECR repository"
  value       = aws_ecr_repository.microservice_ecr_repo.repository_url
}

output "ecr_repository_arn" {
  description = "The ARN of the ECR repository"
  value       = aws_ecr_repository.microservice_ecr_repo.arn
}

output "ecr_repository_name" {
  description = "The name of the ECR repository"
  value       = aws_ecr_repository.microservice_ecr_repo.name
}