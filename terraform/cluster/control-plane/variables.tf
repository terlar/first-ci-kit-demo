variable "deployment" {
  description = "Deployment name"
  type        = string
}

variable "kubernetes_version" {
  description = "Kubernetes control plane version"
  type        = string
}

variable "api_server_cidr" {
  description = "CIDR allowed to reach the API server"
  type        = string
  default     = "0.0.0.0/0"
}
