# ─── Least-privilege baseline: deny owner/editor at project level ─────────────
resource "google_project_iam_binding" "no_basic_owner" {
  project = var.project_id
  role    = "roles/owner"
  members = [] # Explicitly empty — owners only at org level via PAM
}

# ─── Read-only baseline for privileged users (always active) ─────────────────
resource "google_project_iam_binding" "viewer_baseline" {
  project = var.project_id
  role    = "roles/viewer"
  members = var.privileged_users
}

# ─── Time-bound IAM condition example (manual / outside PAM) ─────────────────
# Use for scheduled maintenance windows instead of PAM grants
resource "google_project_iam_member" "compute_admin_maintenance_window" {
  project = var.project_id
  role    = "roles/compute.admin"
  member  = "serviceAccount:maintenance-sa@${var.project_id}.iam.gserviceaccount.com"

  condition {
    title       = "maintenance-window"
    description = "Allow compute admin only during Sunday maintenance windows"
    expression  = <<-EOT
      request.time.getDayOfWeek("America/Chicago") == 0 &&
      request.time.getHours("America/Chicago") >= 2 &&
      request.time.getHours("America/Chicago") < 6
    EOT
  }
}

# ─── Workload Identity for service accounts (no key files) ────────────────────
resource "google_service_account" "privileged_workload" {
  account_id   = "privileged-workload-sa"
  display_name = "Privileged Workload Service Account"
  description  = "SA for workloads requiring elevated access via PAM"
  project      = var.project_id
}

resource "google_service_account_iam_binding" "workload_identity_binding" {
  service_account_id = google_service_account.privileged_workload.name
  role               = "roles/iam.workloadIdentityUser"
  members = [
    "serviceAccount:${var.project_id}.svc.id.goog[default/privileged-workload]"
  ]
}

# ─── Deny policy: block high-risk actions regardless of IAM grants ────────────
resource "google_iam_deny_policy" "block_service_account_key_creation" {
  parent       = "cloudresourcemanager.googleapis.com/projects/${var.project_id}"
  name         = "deny-sa-key-creation"
  display_name = "Block service account key creation"

  rules {
    description = "Prevent all users from creating SA keys (use Workload Identity)"
    deny_rule {
      denied_principals  = ["principalSet://goog/public:all"]
      denied_permissions = [
        "iam.googleapis.com/serviceAccountKeys.create",
        "iam.googleapis.com/serviceAccountKeys.upload",
      ]
      # Exempt the break-glass group
      exception_principals = [
        "principalSet://goog/group/break-glass@${var.project_id}.iam.gserviceaccount.com"
      ]
    }
  }
}