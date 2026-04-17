# Enable the PAM API
resource "google_project_service" "pam" {
  project = var.project_id
  service = "privilegedaccessmanager.googleapis.com"
  disable_on_destroy = false
}

# ─── Entitlement: GKE cluster admin (no approval, 30 min) ────────────────────
resource "google_privileged_access_manager_entitlement" "gke_admin" {
  entitlement_id       = "gke-cluster-admin-jit"
  location             = "global"
  parent               = "projects/${var.project_id}"
  max_request_duration = "1800s" # 30 minutes

  eligible_users {
    principals = var.privileged_users
  }

  privileged_access {
    gcp_iam_access {
      resource      = "//cloudresourcemanager.googleapis.com/projects/${var.project_id}"
      resource_type = "cloudresourcemanager.googleapis.com/Project"

      role_bindings {
        role = "roles/container.clusterAdmin"
      }
    }
  }

  # Auto-approve — but still logged and time-bounded
  approval_workflow {
    manual_approvals {
      require_approver_justification = false
      steps {
        approvals_needed = 0
        approvers {
          principals = var.admin_approvers
        }
      }
    }
  }

  requester_justification_config {
    unstructured {}
  }

  depends_on = [google_project_service.pam]
}