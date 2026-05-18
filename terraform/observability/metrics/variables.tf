variable "deployment" {
  description = "Deployment name"
  type        = string
}

variable "retention_days" {
  description = "Metrics retention period in days"
  type        = number
  default     = 30
}

variable "storage_gb" {
  description = "Persistent volume size for metrics storage"
  type        = number
}
