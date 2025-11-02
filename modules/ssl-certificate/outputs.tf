# modules/ssl-certificate/outputs.tf

output "certificate_arn" {
  description = "ARN of the SSL certificate"
  value       = aws_acm_certificate.luralite_certificate.arn
}

output "certificate_domain" {
  description = "Domain name of the SSL certificate"
  value       = aws_acm_certificate.luralite_certificate.domain_name
}

output "certificate_status" {
  description = "Status of the certificate"
  value       = aws_acm_certificate.luralite_certificate.status
}

output "dns_validation_records" {
  description = "DNS validation records that need to be added to your DNS provider"
  value = {
    for dvo in aws_acm_certificate.luralite_certificate.domain_validation_options : dvo.domain_name => {
      name  = dvo.resource_record_name
      value = dvo.resource_record_value
      type  = dvo.resource_record_type
    }
  }
}