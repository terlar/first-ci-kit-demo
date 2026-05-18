variable "component" {
  description = "Name of the component being provisioned"
  type        = string
}

variable "stack" {
  description = "Name of the stack this component belongs to"
  type        = string
}

variable "deployment" {
  description = "Deployment name (e.g. dev, stg)"
  type        = string
}

variable "settings" {
  description = "Component-specific configuration"
  type        = any
  default     = {}
}
