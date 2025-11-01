# modules/ssl-certificate/main.tf

# SSL Certificate using AWS Certificate Manager
resource "aws_acm_certificate" "luralite_certificate" {
  domain_name       = var.domain_name
  validation_method = "DNS"

  subject_alternative_names = var.subject_alternative_names

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name        = "${var.project_name}-${var.environment}-ssl-cert"
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}

# Certificate validation DNS records
resource "aws_route53_record" "certificate_validation" {
  for_each = {
    for dvo in aws_acm_certificate.luralite_certificate.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = var.route53_zone_id
}

# Certificate validation
# resource "aws_acm_certificate_validation" "certificate_validation" {
#   certificate_arn         = aws_acm_certificate.luralite_certificate.arn
#   validation_record_fqdns = [for record in aws_route53_record.certificate_validation : record.fqdn]
# }