variable "project_id" {
  type        = string
  description = "The ID of the project where audit logs, sinks, and alerts will be configured."
}

variable "siem_topic_name" {
  type        = string
  description = "The name of the Pub/Sub topic that will receive the exported audit logs."
  default     = "audit-logs-siem-export"
}

variable "alert_notification_email" {
  type        = string
  description = "The email address that will receive alerts for PAM approvals and IAM changes."

  validation {
    condition     = can(regex("^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$", var.alert_notification_email))
    error_message = "The alert notification email must be a valid email address format."
  }
}