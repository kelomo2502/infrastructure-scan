# modules/kong-gateway/variables.tf

variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "environment" {
  description = "The deployment environment"
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

variable "kong_target_group_arn" {
  description = "ARN of the Kong target group"
  type        = string
}

variable "alb_security_group_id" {
  description = "ID of the ALB security group"
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

variable "gateway_subnet_ids" {
  description = "List of gateway subnet IDs"
  type        = list(string)
}

variable "kong_image" {
  description = "Kong Docker image"
  type        = string
  default     = "kong/kong:latest-ubuntu"
}

variable "kong_cpu" {
  description = "Kong CPU units"
  type        = string
  default     = "512"
}

variable "kong_memory" {
  description = "Kong memory in MB"
  type        = string
  default     = "1024"
}

variable "kong_desired_count" {
  description = "Number of Kong instances"
  type        = number
  default     = 2
}