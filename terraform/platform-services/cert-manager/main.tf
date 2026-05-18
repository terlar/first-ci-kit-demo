terraform {
  required_version = ">= 1.4"

  backend "s3" {}
}

module "cert_manager" {
  source = "../../modules/component"

  stack      = "platform-services"
  component  = "cert-manager"
  deployment = var.deployment

  settings = {
    acme_email    = var.acme_email
    acme_server   = var.acme_server
    replica_count = var.replica_count
  }
}
