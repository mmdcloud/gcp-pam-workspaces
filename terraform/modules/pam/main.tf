# Enable the PAM API
resource "google_project_service" "pam" {
  project = var.project_id
  service = "privilegedaccessmanager.googleapis.com"
  disable_on_destroy = false
}

# ─── Entitlement: Break-glass BigQuery admin (1-hour max) ───────────────────
resource "google_privileged_access_manager_entitlement" "bq_admin" {
  provider             = google-beta
  entitlement_id       = "bq-admin-breakglass"
  location             = "global"
  parent               = "projects/${var.project_id}"
  max_request_duration = var.pam_entitlement_duration

  eligible_users {
    principals = var.privileged_users
  }

  privileged_access {
    gcp_iam_access {
      resource      = "//cloudresourcemanager.googleapis.com/projects/${var.project_id}"
      resource_type = "cloudresourcemanager.googleapis.com/Project"

      role_bindings {
        role = "roles/bigquery.admin"
        # Optional: condition narrows the grant further at activation time
        condition_expression = "request.time < timestamp('${timeadd(timestamp(), "1h")}')"
      }
    }
  }

  approval_workflow {
    manual_approvals {
      require_approver_justification = true
      steps {
        approvals_needed          = 1
        approver_email_recipients = var.admin_approvers
        approvers {
          principals = var.admin_approvers
        }
      }
    }
  }

  requester_justification_config {
    unstructured {}
  }

  additional_notification_targets {
    admin_email_recipients    = var.admin_approvers
    requester_email_recipients = var.privileged_users
  }

  depends_on = [google_project_service.pam]
}

# ─── Entitlement: GKE cluster admin (no approval, 30 min) ────────────────────
resource "google_privileged_access_manager_entitlement" "gke_admin" {
  provider             = google-beta
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

# ─── Entitlement: Secret Manager accessor (requires justification) ────────────
resource "google_privileged_access_manager_entitlement" "secret_accessor" {
  provider             = google-beta
  entitlement_id       = "secret-accessor-jit"
  location             = "global"
  parent               = "projects/${var.project_id}"
  max_request_duration = "3600s"

  eligible_users {
    principals = var.privileged_users
  }

  privileged_access {
    gcp_iam_access {
      resource      = "//cloudresourcemanager.googleapis.com/projects/${var.project_id}"
      resource_type = "cloudresourcemanager.googleapis.com/Project"

      role_bindings {
        role = "roles/secretmanager.secretAccessor"
      }
    }
  }

  approval_workflow {
    manual_approvals {
      require_approver_justification = true
      steps {
        approvals_needed          = 1
        approver_email_recipients = var.admin_approvers
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