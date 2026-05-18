terraform {
  required_version = ">= 1.4"
}

resource "terraform_data" "this" {
  input = {
    stack      = var.stack
    component  = var.component
    deployment = var.deployment
    settings   = var.settings
  }

  provisioner "local-exec" {
    command = "echo 'Provisioning ${var.stack}/${var.component} for ${var.deployment}'"
  }
}
