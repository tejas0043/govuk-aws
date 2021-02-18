/**
* ## Project: infra-google-cloud-cdn
*
* This project creates the Google Cloud CDN which fronts the Google Cloud Storage
* bucket which contains mirrored GOV.UK static pages
*
*/

variable "google_project_id" {
  type        = string
  description = "Google project ID"
  default     = "eu-west2"
}

variable "google_project_no" {
  type        = number
  description = "Google project no"
}

variable "google_region" {
  type        = string
  description = "Google region the provider"
  default     = "eu-west2"
}

variable "google_environment" {
  type        = string
  description = "Google environment, which is govuk environment. e.g: staging"
  default     = ""
}

variable "remote_state_bucket" {
  type        = string
  description = "GCS bucket we store our terraform state in"
}

variable "remote_state_infra_google_mirror_bucket_prefix" {
  type        = string
  description = "GCS bucket prefix where the infra-google-mirror-bucket state files are stored"
}

variable "imported_www_gov_uk_private_key" {
  type        = string
  description = "Imported www.gov.uk private key"
}

variable "imported_www_gov_uk_cert" {
  type        = string
  description = "Imported www.gov.uk certificate"
}

variable "imported_wildcard_publishing_service_gov_uk_private_key" {
  type        = string
  description = "Imported *.publishing.service.gov.uk private key"
}

variable "imported_wildcard_publishing_service_gov_uk_cert" {
  type        = string
  description = "Imported *.publishing.service.gov.uk certificate"
}


# Resources
# --------------------------------------------------------------

terraform {
  backend "gcs" {}
  required_version = "= 0.13.6"

  required_providers {
    gcp = {
      source  = "hashicorp/google"
      version = "~> 3.57.0"
    }
  }
}

provider "google" {
  region  = var.google_region
  project = var.google_project_id
}

data "terraform_remote_state" "infra_google_mirror_bucket" {
  backend = "gcs"

  config = {
    bucket = var.remote_state_bucket
    prefix = var.remote_state_infra_google_mirror_bucket_prefix
  }
}


resource "google_compute_backend_bucket" "cdn_backend_bucket" {
  name        = "govuk-${var.google_environment}-cdn-backend-bucket"
  description = "Backend bucket for serving static content through CDN"
  bucket_name = data.terraform_remote_state.infra_google_mirror_bucket.outputs.bucket_name
  enable_cdn  = true
  project     = var.google_project_id
}

resource "google_compute_url_map" "cdn_url_map" {
  name            = "cdn-url-map"
  description     = "CDN URL map to cdn_backend_bucket"
  default_service = google_compute_backend_bucket.cdn_backend_bucket.self_link
  project         = var.google_project_id

  host_rule {
    hosts        = ["www.gov.uk"]
    path_matcher = "wwwgovuk"
  }

  path_matcher {
    name            = "wwwgovuk"
    default_service = google_compute_backend_bucket.cdn_backend_bucket.self_link

    path_rule {
      paths   = ["/*"]
      service = google_compute_backend_bucket.cdn_backend_bucket.self_link
    }

    path_rule {
      paths   = ["/www.gov.uk"]
      service = google_compute_backend_bucket.cdn_backend_bucket.self_link
    }
  }
}

resource "google_compute_ssl_certificate" "imported_www_gov_uk" {
  name_prefix = "imported-www-gov-uk-"
  description = "imported www.gov.uk cert"
  private_key = var.imported_www_gov_uk_private_key
  certificate = var.imported_www_gov_uk_cert
  project     = var.google_project_id

  lifecycle {
    create_before_destroy = true
  }
}

resource "google_compute_ssl_certificate" "imported_wildcard_publishing_service_gov_uk" {
  name_prefix = "imported-wild-pub-srv-gov-uk-"
  description = "imported wildcard publishing.service.gov.uk cert"
  private_key = var.imported_wildcard_publishing_service_gov_uk_private_key
  certificate = var.imported_wildcard_publishing_service_gov_uk_cert
  project     = var.google_project_id

  lifecycle {
    create_before_destroy = true
  }
}

resource "google_compute_target_https_proxy" "cdn_https_proxy" {
  name             = "cdn-https-proxy"
  url_map          = google_compute_url_map.cdn_url_map.self_link
  ssl_certificates = [google_compute_ssl_certificate.imported_www_gov_uk.self_link, google_compute_ssl_certificate.imported_wildcard_publishing_service_gov_uk.self_link]
  project          = var.google_project_id
}

resource "google_compute_global_address" "cdn_public_address" {
  name         = "cdn-public-address"
  ip_version   = "IPV4"
  address_type = "EXTERNAL"
  project      = var.google_project_id
}

resource "google_compute_global_forwarding_rule" "cdn_global_forwarding_rule" {
  name       = "cdn-global-forwarding-https-rule"
  target     = google_compute_target_https_proxy.cdn_https_proxy.self_link
  ip_address = google_compute_global_address.cdn_public_address.address
  port_range = "443"
  project    = var.google_project_id
}
