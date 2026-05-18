terraform {
  required_version = ">= 1.4"

  backend "s3" {}
}

module "certs" {
  source = "../../modules/component"

  stack      = "security"
  component  = "certs"
  deployment = var.deployment

  settings = {
    root_domain    = var.root_domain
    validity_hours = var.validity_hours
  }
}
