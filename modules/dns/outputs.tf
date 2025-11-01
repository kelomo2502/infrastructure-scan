# modules/dns/outputs.tf

output "hosted_zone_id" {
  description = "ID of the Route53 hosted zone"
  value       = aws_route53_zone.luralite_zone.zone_id
}

output "hosted_zone_name_servers" {
  description = "Name servers for the hosted zone"
  value       = aws_route53_zone.luralite_zone.name_servers
}

output "domain_name" {
  description = "The domain name"
  value       = var.domain_name
}