module "pam" {
  source                   = "./modules/pam"
  project_id               = var.project_id
  privileged_users         = var.privileged_users
  admin_approvers          = var.admin_approvers
  pam_entitlement_duration = var.pam_entitlement_duration
}

module "iam" {
  source           = "./modules/iam"
  project_id       = var.project_id
  privileged_users = var.privileged_users
}

module "org_policy" {
  source     = "./modules/org-policy"
  org_id     = var.org_id
  project_id = var.project_id
}

module "vpc_sc" {
  source         = "./modules/vpc-sc"
  org_id         = var.org_id
  project_number = var.project_number
  privileged_users         = var.privileged_users
}

module "audit" {
  source                   = "./modules/audit"
  project_id               = var.project_id
  siem_topic_name          = var.siem_topic_name
  alert_notification_email = var.alert_notification_email
}