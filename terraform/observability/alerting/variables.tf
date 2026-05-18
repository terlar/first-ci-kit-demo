variable "deployment" {
  description = "Deployment name"
  type        = string
}

variable "slack_channel" {
  description = "Slack channel for alert notifications"
  type        = string
  default     = "#alerts"
}

variable "pagerduty_integration_key" {
  description = "PagerDuty integration key (leave empty to disable)"
  type        = string
  default     = ""
  sensitive   = true
}
