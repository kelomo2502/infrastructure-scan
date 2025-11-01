# modules/service-discovery/main.tf

# CloudMap Service Discovery Namespace
resource "aws_service_discovery_private_dns_namespace" "luralite_namespace" {
  name        = "${var.project_name}.${var.environment}.local"
  description = "Service discovery namespace for ${var.project_name} ${var.environment}"
  vpc         = var.vpc_id

  tags = {
    Name        = "${var.project_name}-${var.environment}-service-discovery"
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}