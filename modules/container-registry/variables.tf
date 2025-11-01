# modules/container-registry/variables.tf

variable "project_name" {
  description = "Name of the project"
  type        = string
  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.project_name))
    error_message = "Project name must contain only lowercase letters, numbers, and hyphens."
  }
}

variable "environment" {
  description = "The deployment environment"
  type        = string
  validation {
    condition     = contains(["staging", "production"], var.environment)
    error_message = "Environment must be either 'staging' or 'production'."
  }
}

variable "service_name" {
  description = "Name of the microservice (e.g., identity-svc, payment-svc)"
  type        = string
  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.service_name))
    error_message = "Service name must contain only lowercase letters, numbers, and hyphens."
  }
}

variable "ci_cd_iam_roles" {
  description = "List of IAM role ARNs that should have push access to the ECR repository (GitHub Actions, etc.)"
  type        = list(string)
  default     = []
}