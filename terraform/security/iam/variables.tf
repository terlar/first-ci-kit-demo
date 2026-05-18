variable "deployment" {
  description = "Deployment name"
  type        = string
}

variable "permission_boundary_arn" {
  description = "ARN of the IAM permission boundary policy"
  type        = string
  default     = ""
}

variable "workload_accounts" {
  description = "List of workload account IDs granted assume-role"
  type        = list(string)
  default     = []
}
