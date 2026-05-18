output "id" {
  description = "Unique identifier for this component instance"
  value       = terraform_data.this.id
}

output "deployment" {
  description = "Deployment this component was provisioned for"
  value       = var.deployment
}
