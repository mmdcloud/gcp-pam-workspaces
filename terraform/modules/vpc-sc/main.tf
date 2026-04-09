# ─── Access policy (org-level) ────────────────────────────────────────────────
resource "google_access_context_manager_access_policy" "pam_policy" {
  parent = "organizations/${var.org_id}"
  title  = "PAM Access Policy"
}

# ─── Access level: corporate network + managed devices ───────────────────────
resource "google_access_context_manager_access_level" "corp_network" {
  parent = "accessPolicies/${google_access_context_manager_access_policy.pam_policy.name}"
  name   = "accessPolicies/${google_access_context_manager_access_policy.pam_policy.name}/accessLevels/corp_network"
  title  = "Corporate network and managed devices"

  basic {
    conditions {
      ip_subnetworks = ["203.0.113.0/24"] # Replace with your corp CIDR
      device_policy {
        require_corp_owned      = true
        require_screen_lock     = true
        allowed_encryption_statuses = ["ENCRYPTED"]
      }
    }
  }
}

# ─── Service perimeter: protect sensitive APIs ────────────────────────────────
resource "google_access_context_manager_service_perimeter" "pam_perimeter" {
  parent = "accessPolicies/${google_access_context_manager_access_policy.pam_policy.name}"
  name   = "accessPolicies/${google_access_context_manager_access_policy.pam_policy.name}/servicePerimeters/pam_perimeter"
  title  = "PAM Protected Perimeter"

  status {
    resources = ["projects/${var.project_number}"]

    restricted_services = [
      "bigquery.googleapis.com",
      "storage.googleapis.com",
      "secretmanager.googleapis.com",
      "sqladmin.googleapis.com",
      "container.googleapis.com",
    ]

    access_levels = [
      google_access_context_manager_access_level.corp_network.name
    ]

    ingress_policies {
      ingress_from {
        identity_type = "IDENTITY_TYPE_UNSPECIFIED"
        identities    = var.privileged_users
        sources {
          access_level = google_access_context_manager_access_level.corp_network.name
        }
      }
      ingress_to {
        resources = ["*"]
        operations {
          service_name = "bigquery.googleapis.com"
          method_selectors { method = "*" }
        }
        operations {
          service_name = "secretmanager.googleapis.com"
          method_selectors { method = "*" }
        }
      }
    }

    egress_policies {
      egress_from {
        identity_type = "IDENTITY_TYPE_UNSPECIFIED"
        identities    = var.privileged_users
      }
      egress_to {
        resources = ["*"]
        operations {
          service_name = "storage.googleapis.com"
          method_selectors { method = "google.storage.objects.get" }
        }
      }
    }
  }
}