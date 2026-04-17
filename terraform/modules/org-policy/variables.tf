variable "project_id" {
  type        = string
  description = "The ID of the project where project-level policies are applied."
}

variable "org_id" {
  type        = string
  description = "The numeric Organization ID for org-wide policy enforcement."
}

variable "customer_id" {
  type        = string
  description = "The Google Workspace/Cloud Identity Customer ID (e.g., C0xxxxxxx) for the allowedPolicyMemberDomains constraint."
  
  validation {
    condition     = can(regex("^C[a-zA-Z0-9]+$", var.customer_id))
    error_message = "The Customer ID must start with 'C' followed by alphanumeric characters."
  }
}