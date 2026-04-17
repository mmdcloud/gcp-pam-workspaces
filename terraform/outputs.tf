output "gke_entitlement_id" {
  description = "GKE admin PAM entitlement ID"
  value       = module.pam.gke_entitlement_id
}

output "vpc_sc_perimeter_name" {
  description = "VPC SC perimeter resource name"
  value       = module.vpc_sc.perimeter_name
}

output "audit_pubsub_topic" {
  description = "Pub/Sub topic for SIEM audit export"
  value       = module.audit.pubsub_topic_id
}