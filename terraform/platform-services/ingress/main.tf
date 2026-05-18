terraform {
  required_version = ">= 1.4"

  backend "local" {}
}

module "ingress" {
  source = "../../modules/component"

  stack      = "platform-services"
  component  = "ingress"
  deployment = var.deployment

  settings = {
    replica_count         = var.replica_count
    enable_proxy_protocol = var.enable_proxy_protocol
  }
}
