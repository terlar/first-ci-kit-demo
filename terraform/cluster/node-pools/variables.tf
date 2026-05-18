variable "deployment" {
  description = "Deployment name"
  type        = string
}

variable "instance_type" {
  description = "Node instance type"
  type        = string
}

variable "min_nodes" {
  description = "Minimum nodes per pool"
  type        = number
}

variable "max_nodes" {
  description = "Maximum nodes per pool"
  type        = number
}
