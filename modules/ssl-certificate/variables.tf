# modules/ssl-certificate/variables.tf

variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "environment" {
  description = "The deployment environment"
  type        = string
}

variable "domain_name" {
  description = "Primary domain name for the SSL certificate"
  type        = string
}

variable "subject_alternative_names" {
  description = "List of subject alternative names for the SSL certificate"
  type        = list(string)
  default     = []
}

variable "route53_zone_id" {
  description = "Route53 zone ID for DNS validation"
  type        = string
}