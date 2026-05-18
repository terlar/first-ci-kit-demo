terraform {
  required_version = ">= 1.4"

  backend "local" {}
}

module "metrics" {
  source = "../../modules/component"

  stack      = "observability"
  component  = "metrics"
  deployment = var.deployment

  settings = {
    retention_days = var.retention_days
    storage_gb     = var.storage_gb
  }
}
