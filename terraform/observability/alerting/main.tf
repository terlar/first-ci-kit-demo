terraform {
  required_version = ">= 1.4"

  backend "s3" {}
}

module "alerting" {
  source = "../../modules/component"

  stack      = "observability"
  component  = "alerting"
  deployment = var.deployment

  settings = {
    slack_channel = var.slack_channel
  }
}
