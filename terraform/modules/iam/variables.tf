variable "project_id" {
  type        = string
  description = "The ID of the Google Cloud project where resources will be managed."
}

variable "privileged_users" {
  type        = list(string)
  description = "A list of IAM identities (e.g., user:email@example.com) that receive the baseline Viewer role."
  default     = []
}

# Note: While not explicitly called as a variable in all your resources, 
# it's good practice to define the region for the provider or maintenance windows.
variable "region" {
  type        = string
  description = "The default GCP region for resources."
  default     = "us-central1"
}