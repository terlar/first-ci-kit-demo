variable "deployment" {
  description = "Deployment name"
  type        = string
}

variable "acme_email" {
  description = "Email address for ACME certificate registration"
  type        = string
}

variable "acme_server" {
  description = "ACME server URL"
  type        = string
  default     = "https://acme-v02.api.letsencrypt.org/directory"
}

variable "replica_count" {
  description = "Number of cert-manager replicas"
  type        = number
  default     = 1
}
