output "gke_entitlement_id" {
  value = google_privileged_access_manager_entitlement.gke_admin.entitlement_id
}