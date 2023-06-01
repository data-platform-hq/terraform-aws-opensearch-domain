output "arn" {
  description = "The Amazon Resource Name (ARN) of the OpenSearch domain"
  value       = try(aws_opensearch_domain.this[0].arn, null)
}

output "domain_id" {
  description = "Unique identifier for the domain"
  value       = try(aws_opensearch_domain.this[0].domain_id, null)
}

output "domain_name" {
  description = "Name of the OpenSearch domain"
  value       = try(aws_opensearch_domain.this[0].domain_name, null)
}

output "endpoint" {
  description = "Domain-specific endpoint used to submit index, search, and data upload requests"
  value       = try(aws_opensearch_domain.this[0].endpoint, null)
}

output "dashboard_endpoint" {
  description = "Domain-specific endpoint for Dashboard without https scheme"
  value       = try(aws_opensearch_domain.this[0].dashboard_endpoint, null)
}
