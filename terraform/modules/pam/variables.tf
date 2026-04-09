variable "project_id" {
  type        = string
  description = "The ID of the Google Cloud project where PAM entitlements will be created."
}

variable "privileged_users" {
  type        = list(string)
  description = "List of users eligible to request elevated access (e.g., ['user:alice@example.com'])."
}

variable "admin_approvers" {
  type        = list(string)
  description = "List of users or groups authorized to approve PAM requests (e.g., ['group:security-admins@example.com'])."
}

variable "pam_entitlement_duration" {
  type        = string
  description = "The maximum allowed duration for the BigQuery break-glass entitlement (e.g., '3600s')."
  default     = "3600s"

  validation {
    condition     = can(regex("^[0-9]+s$", var.pam_entitlement_duration))
    error_message = "The duration must be a string ending in 's', such as '3600s' or '1800s'."
  }
}