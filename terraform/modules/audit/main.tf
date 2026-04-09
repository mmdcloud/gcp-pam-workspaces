# ─── Enable Data Access audit logs for sensitive services ─────────────────────
resource "google_project_iam_audit_config" "pam_audit" {
  project = var.project_id
  service = "allServices"

  audit_log_config {
    log_type = "ADMIN_READ"
  }
  audit_log_config {
    log_type = "DATA_READ"
  }
  audit_log_config {
    log_type = "DATA_WRITE"
  }
}

# ─── Pub/Sub topic for SIEM export ───────────────────────────────────────────
resource "google_pubsub_topic" "audit_export" {
  name    = var.siem_topic_name
  project = var.project_id

  message_retention_duration = "604800s" # 7 days
}

# ─── Log sink: stream audit logs to Pub/Sub ───────────────────────────────────
resource "google_logging_project_sink" "pam_sink" {
  name        = "pam-audit-sink"
  project     = var.project_id
  destination = "pubsub.googleapis.com/projects/${var.project_id}/topics/${google_pubsub_topic.audit_export.name}"

  filter = <<-EOT
    protoPayload.serviceName="privilegedaccessmanager.googleapis.com" OR
    protoPayload.methodName=~".*SetIamPolicy$" OR
    protoPayload.methodName=~".*CreateServiceAccountKey$" OR
    logName=~"cloudaudit.googleapis.com%2Fdata_access" AND
    protoPayload.resourceName=~"projects/${var.project_id}"
  EOT

  unique_writer_identity = true
}

# ─── Grant the sink's SA publish rights ───────────────────────────────────────
resource "google_pubsub_topic_iam_member" "sink_publisher" {
  project = var.project_id
  topic   = google_pubsub_topic.audit_export.name
  role    = "roles/pubsub.publisher"
  member  = google_logging_project_sink.pam_sink.writer_identity
}

# ─── Cloud Monitoring: alert on PAM grant approvals ──────────────────────────
resource "google_monitoring_notification_channel" "email_alert" {
  display_name = "PAM Alert Email"
  type         = "email"
  project      = var.project_id

  labels = {
    email_address = var.alert_notification_email
  }
}

resource "google_monitoring_alert_policy" "pam_grant_alert" {
  display_name = "Privileged access grant approved"
  project      = var.project_id
  combiner     = "OR"

  conditions {
    display_name = "PAM entitlement grant"
    condition_matched_log {
      filter         = <<-EOT
        protoPayload.serviceName="privilegedaccessmanager.googleapis.com" AND
        protoPayload.methodName="ApproveGrant"
      EOT
      label_extractors = {
        "entitlement" = "EXTRACT(protoPayload.resourceName)"
        "requester"   = "EXTRACT(protoPayload.authenticationInfo.principalEmail)"
      }
    }
  }

  notification_channels = [google_monitoring_notification_channel.email_alert.name]

  alert_strategy {
    notification_rate_limit {
      period = "300s"
    }
  }
}

resource "google_monitoring_alert_policy" "iam_policy_change_alert" {
  display_name = "IAM policy changed on project"
  project      = var.project_id
  combiner     = "OR"

  conditions {
    display_name = "SetIamPolicy detected"
    condition_matched_log {
      filter = <<-EOT
        protoPayload.methodName="SetIamPolicy" AND
        resource.type="project"
      EOT
    }
  }

  notification_channels = [google_monitoring_notification_channel.email_alert.name]

  alert_strategy {
    notification_rate_limit {
      period = "60s"
    }
  }
}