variable "deployment" {
  description = "Deployment name"
  type        = string
}

variable "retention_days" {
  description = "Log retention period in days"
  type        = number
  default     = 14
}

variable "storage_gb" {
  description = "Persistent volume size for log storage"
  type        = number
}
