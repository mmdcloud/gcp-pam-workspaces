terraform {
  required_version = ">= 1.6"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
    google-beta = {
      source  = "hashicorp/google-beta"
      version = "~> 5.0"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

provider "google-beta" {
  project = var.project_id
  region  = var.region
}

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
  source   = "./modules/org-policy"
  org_id   = var.org_id
  project_id = var.project_id
}

module "vpc_sc" {
  source         = "./modules/vpc-sc"
  org_id         = var.org_id
  project_id     = var.project_id
  project_number = var.project_number
}

module "audit" {
  source                   = "./modules/audit"
  project_id               = var.project_id
  org_id                   = var.org_id
  siem_topic_name          = var.siem_topic_name
  alert_notification_email = var.alert_notification_email
}