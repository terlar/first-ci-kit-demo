terraform {
  required_version = ">= 1.4"

  backend "s3" {}
}

module "node_pools" {
  source = "../../modules/component"

  stack      = "cluster"
  component  = "node-pools"
  deployment = var.deployment

  settings = {
    instance_type = var.instance_type
    min_nodes     = var.min_nodes
    max_nodes     = var.max_nodes
  }
}
