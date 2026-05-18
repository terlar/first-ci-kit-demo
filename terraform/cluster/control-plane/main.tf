terraform {
  required_version = ">= 1.4"

  backend "local" {}
}

module "control_plane" {
  source = "../../modules/component"

  stack      = "cluster"
  component  = "control-plane"
  deployment = var.deployment

  settings = {
    kubernetes_version = var.kubernetes_version
    api_server_cidr    = var.api_server_cidr
  }
}
