terraform {
  required_version = ">= 1.4"

  backend "local" {}
}

module "logging" {
  source = "../../modules/component"

  stack      = "observability"
  component  = "logging"
  deployment = var.deployment

  settings = {
    retention_days = var.retention_days
    storage_gb     = var.storage_gb
  }
}
