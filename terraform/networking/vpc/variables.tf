variable "deployment" {
  description = "Deployment name"
  type        = string
}

variable "cidr_block" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "availability_zones" {
  description = "Number of availability zones to span"
  type        = number
  default     = 3
}
