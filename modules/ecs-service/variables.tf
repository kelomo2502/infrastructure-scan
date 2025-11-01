# modules/ecs-service/variables.tf

variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "environment" {
  description = "The deployment environment"
  type        = string
}

variable "service_name" {
  description = "Name of the microservice"
  type        = string
}

variable "ecs_cluster_id" {
  description = "ID of the ECS cluster"
  type        = string
}

variable "ecs_task_execution_role_arn" {
  description = "ARN of the ECS task execution role"
  type        = string
}

variable "ecr_repository_url" {
  description = "ECR repository URL for the service"
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC"
  type        = string
}

variable "vpc_cidr_block" {
  description = "CIDR block of the VPC"
  type        = string
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs"
  type        = list(string)
}

variable "kong_security_group_id" {
  description = "ID of the Kong security group"
  type        = string
}

variable "service_discovery_namespace_id" {
  description = "CloudMap namespace ID for service discovery"
  type        = string
}

variable "container_port" {
  description = "Container port the service listens on"
  type        = number
  default     = 8080
}

variable "cpu" {
  description = "CPU units for the task"
  type        = number
  default     = 256
}

variable "memory" {
  description = "Memory in MB for the task"
  type        = number
  default     = 512
}


variable "desired_count" {
  description = "Number of task instances to run"
  type        = number
  default     = 2
}

variable "image_tag" {
  description = "Docker image tag"
  type        = string
  default     = "latest"
}

variable "target_group_arn" {
  description = "ALB target group ARN (if service needs direct internet access)"
  type        = string
  default     = null
}

variable "environment_variables" {
  description = "Environment variables for the container"
  type        = list(map(string))
  default     = []
}

variable "secrets" {
  description = "Secrets from AWS Secrets Manager"
  type        = list(map(string))
  default     = []
}

variable "secrets_manager_arns" {
  description = "ARNs of secrets in Secrets Manager that this service can access"
  type        = list(string)
  default     = []
}

variable "health_check" {
  description = "Health check configuration"
  type        = any
  default = {
    command     = ["CMD-SHELL", "echo healthy || exit 1"]
    interval    = 30
    timeout     = 5
    retries     = 3
    startPeriod = 40
  }
}