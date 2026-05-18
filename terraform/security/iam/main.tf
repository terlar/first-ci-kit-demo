terraform {
  required_version = ">= 1.4"

  backend "local" {}
}

module "iam" {
  source = "../../modules/component"

  stack      = "security"
  component  = "iam"
  deployment = var.deployment

  settings = {
    permission_boundary_arn = var.permission_boundary_arn
    workload_accounts       = var.workload_accounts
  }
}
