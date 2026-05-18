variable "deployment" {
  description = "Deployment name"
  type        = string
}

variable "zone_name" {
  description = "DNS zone name"
  type        = string
}

variable "ttl_seconds" {
  description = "Default TTL for DNS records"
  type        = number
  default     = 300
}
