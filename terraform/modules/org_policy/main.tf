# ─── Restrict identities allowed to access the project ───────────────────────
resource "google_org_policy_policy" "restrict_resource_policies" {
  name   = "projects/${var.project_id}/policies/iam.allowedPolicyMemberDomains"
  parent = "projects/${var.project_id}"

  spec {
    rules {
      values {
        allowed_values = [
          "C0xxxxxxx" # your Google Workspace customer ID
        ]
      }
    }
  }
}

# ─── Disable service account key creation org-wide ────────────────────────────
resource "google_org_policy_policy" "disable_sa_key_creation" {
  name   = "organizations/${var.org_id}/policies/iam.disableServiceAccountKeyCreation"
  parent = "organizations/${var.org_id}"

  spec {
    rules {
      enforce = true
    }
  }
}

# ─── Require OS Login for all VMs ─────────────────────────────────────────────
resource "google_org_policy_policy" "require_os_login" {
  name   = "projects/${var.project_id}/policies/compute.requireOsLogin"
  parent = "projects/${var.project_id}"

  spec {
    rules {
      enforce = true
    }
  }
}

# ─── Restrict which services can be used (allowlist) ─────────────────────────
resource "google_org_policy_policy" "restrict_cloud_run_region" {
  name   = "projects/${var.project_id}/policies/gcp.resourceLocations"
  parent = "projects/${var.project_id}"

  spec {
    rules {
      values {
        allowed_values = ["in:us-locations"]
      }
    }
  }
}

# ─── Disable public IP on Cloud SQL ──────────────────────────────────────────
resource "google_org_policy_policy" "disable_cloudsql_public_ip" {
  name   = "projects/${var.project_id}/policies/sql.restrictPublicIp"
  parent = "projects/${var.project_id}"

  spec {
    rules {
      enforce = true
    }
  }
}