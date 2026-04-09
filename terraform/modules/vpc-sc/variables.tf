variable "org_id" {
  type        = string
  description = "The numeric Organization ID where the Access Policy will be created."
}

variable "project_number" {
  type        = string
  description = "The numeric Project Number (not Project ID) to be protected by the service perimeter."
}

variable "privileged_users" {
  type        = list(string)
  description = "List of identities allowed to ingress/egress the perimeter (e.g., ['user:admin@example.com'])."
}

# Optional: Add a variable for the corporate CIDR if you want to avoid hardcoding
variable "corp_cidr_range" {
  type        = string
  description = "The CIDR range for the corporate network."
  default     = "203.0.113.0/24"
}