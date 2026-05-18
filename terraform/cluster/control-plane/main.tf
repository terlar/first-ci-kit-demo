terraform {
  required_version = ">= 1.4"

  backend "s3" {}
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
