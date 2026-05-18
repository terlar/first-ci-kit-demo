terraform {
  required_version = ">= 1.4"

  backend "local" {}
}

module "postgres" {
  source = "../../modules/component"

  stack      = "database"
  component  = "postgres"
  deployment = var.deployment

  settings = {
    instance_class = var.instance_class
    engine_version = var.engine_version
    storage_gb     = var.storage_gb
    multi_az       = var.multi_az
  }
}
