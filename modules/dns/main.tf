# modules/dns/main.tf

# Route53 Hosted Zone for the domain
resource "aws_route53_zone" "luralite_zone" {
  name = var.domain_name

  tags = {
    Name        = "${var.project_name}-${var.environment}-route53-zone"
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}