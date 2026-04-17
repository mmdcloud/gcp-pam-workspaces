variable "org_id" {
  description = "GCP Organization ID"
  type        = string
}

variable "location" {
  description = "Location"
  type        = string
}

variable "project_id" {
  description = "GCP Project ID"
  type        = string
  default     = "encoded-alpha-457108-e8"
}

variable "project_number" {
  description = "GCP Project number"
  type        = string
}

variable "region" {
  description = "Default region"
  type        = string
  default     = "us-central1"
}

variable "privileged_users" {
  description = "List of users who may request privileged access"
  type        = list(string)
  # e.g. ["user:alice@example.com", "user:bob@example.com"]
}

variable "admin_approvers" {
  description = "Users who can approve PAM entitlement requests"
  type        = list(string)
}

variable "pam_entitlement_duration" {
  description = "Max duration for a PAM grant (ISO 8601)"
  type        = string
  default     = "3600s" # 1 hour
}

variable "siem_topic_name" {
  description = "Pub/Sub topic for SIEM export"
  type        = string
  default     = "pam-audit-export"
}

variable "alert_notification_email" {
  description = "Email for privileged access alerts"
  type        = string
}