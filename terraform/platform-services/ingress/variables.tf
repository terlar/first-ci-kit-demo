variable "deployment" {
  description = "Deployment name"
  type        = string
}

variable "replica_count" {
  description = "Number of ingress controller replicas"
  type        = number
  default     = 2
}

variable "enable_proxy_protocol" {
  description = "Enable PROXY protocol on the load balancer"
  type        = bool
  default     = false
}
