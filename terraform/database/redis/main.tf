terraform {
  required_version = ">= 1.4"

  backend "s3" {}
}

module "redis" {
  source = "../../modules/component"

  stack      = "database"
  component  = "redis"
  deployment = var.deployment

  settings = {
    node_type      = var.node_type
    num_replicas   = var.num_replicas
    engine_version = var.engine_version
  }
}
