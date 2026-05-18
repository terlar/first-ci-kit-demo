terraform {
  required_version = ">= 1.4"

  backend "local" {}
}

module "dns" {
  source = "../../modules/component"

  stack      = "networking"
  component  = "dns"
  deployment = var.deployment

  settings = {
    zone_name   = var.zone_name
    ttl_seconds = var.ttl_seconds
  }
}
