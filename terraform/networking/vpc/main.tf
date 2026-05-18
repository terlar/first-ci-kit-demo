terraform {
  required_version = ">= 1.4"

  backend "s3" {}
}

module "vpc" {
  source = "../../modules/component"

  stack      = "networking"
  component  = "vpc"
  deployment = var.deployment

  settings = {
    cidr_block         = var.cidr_block
    availability_zones = var.availability_zones
  }
}
