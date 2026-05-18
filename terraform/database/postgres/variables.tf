variable "deployment" {
  description = "Deployment name"
  type        = string
}

variable "instance_class" {
  description = "Database instance class"
  type        = string
}

variable "engine_version" {
  description = "PostgreSQL engine version"
  type        = string
  default     = "16"
}

variable "storage_gb" {
  description = "Allocated storage in GB"
  type        = number
}

variable "multi_az" {
  description = "Enable multi-AZ deployment"
  type        = bool
  default     = false
}
