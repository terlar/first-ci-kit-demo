variable "deployment" {
  description = "Deployment name"
  type        = string
}

variable "root_domain" {
  description = "Root domain for certificate issuance"
  type        = string
}

variable "validity_hours" {
  description = "Certificate validity period in hours"
  type        = number
  default     = 8760
}
