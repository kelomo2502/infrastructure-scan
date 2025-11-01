# environments/staging/outputs.tf

# ALB Outputs
output "alb_dns_name" {
  description = "DNS name of the Application Load Balancer"
  value       = module.load_balancer.alb_dns_name
}

output "alb_zone_id" {
  description = "Zone ID of the Application Load Balancer"
  value       = module.load_balancer.alb_zone_id
}

# ECR Outputs
output "ecr_identity_svc_url" {
  description = "ECR repository URL for identity service"
  value       = module.ecr_identity_svc.ecr_repository_url
}

output "ecr_payment_svc_url" {
  description = "ECR repository URL for payment service"
  value       = module.ecr_payment_svc.ecr_repository_url
}

output "ecr_api_gateway_url" {
  description = "ECR repository URL for API gateway"
  value       = module.ecr_api_gateway.ecr_repository_url
}

# ECS Outputs
output "ecs_cluster_name" {
  description = "Name of the ECS cluster"
  value       = module.ecs_cluster.ecs_cluster_name
}

output "ecs_task_execution_role_arn" {
  description = "ARN of the ECS task execution role"
  value       = module.ecs_cluster.ecs_task_execution_role_arn
}

# Network Outputs
output "vpc_id" {
  description = "ID of the VPC"
  value       = module.network.vpc_id
}

output "public_subnet_ids" {
  description = "List of public subnet IDs"
  value       = module.network.public_subnet_ids
}

output "gateway_subnet_ids" {
  description = "List of gateway subnet IDs"
  value       = module.network.gateway_subnet_ids
}

output "private_subnet_ids" {
  description = "List of private subnet IDs"
  value       = module.network.private_subnet_ids
}

# DNS Outputs
output "hosted_zone_id" {
  description = "ID of the Route53 hosted zone"
  value       = module.dns.hosted_zone_id
}

output "hosted_zone_name_servers" {
  description = "Name servers for the hosted zone"
  value       = module.dns.hosted_zone_name_servers
}

# SSL Certificate Outputs
output "ssl_certificate_arn" {
  description = "ARN of the SSL certificate"
  value       = module.ssl_certificate.certificate_arn
}

output "ssl_certificate_status" {
  description = "Status of the SSL certificate"
  value       = module.ssl_certificate.certificate_status
}

# Kong Target Group Output
output "kong_target_group_arn" {
  description = "ARN of the Kong target group"
  value       = module.load_balancer.kong_target_group_arn
}

# Add these database outputs

output "rds_endpoint" {
  description = "RDS PostgreSQL endpoint"
  value       = module.database.rds_endpoint
  sensitive   = true
}

output "rds_database_name" {
  description = "RDS database name"
  value       = module.database.rds_database_name
}

output "rds_port" {
  description = "RDS port"
  value       = module.database.rds_port
}

# Add these Redis outputs

output "redis_endpoint" {
  description = "Redis cache endpoint"
  value       = module.redis_cache.redis_endpoint
}

output "redis_port" {
  description = "Redis cache port"
  value       = module.redis_cache.redis_port
}

# Add these RabbitMQ outputs

output "rabbitmq_endpoints" {
  description = "RabbitMQ broker endpoints"
  value       = module.rabbitmq.rabbitmq_endpoints
  sensitive   = true
}