terraform {
  required_providers {
    google = { source = "hashicorp/google", version = "~> 5.45" }
    time   = { source = "hashicorp/time", version = "~> 0.11" }
  }
}

provider "google" {
  project = "project-cbc6aa96-d900-4564-a30"
  region  = "us-central1"
}

variable "project_id" { default = "project-cbc6aa96-d900-4564-a30" }
variable "region" { default = "us-central1" }

resource "google_kms_key_ring" "ring" {
  name     = "mc-day7-ring"
  location = var.region
}

# Rotation every 90 days; set the next rotation 24h from now for demo
resource "google_kms_crypto_key" "key" {
  name            = "mc-day7-key"
  key_ring        = google_kms_key_ring.ring.id
  purpose         = "ENCRYPT_DECRYPT"
  rotation_period = "7776000s" # 90 days
}

output "gcp_ring_id" { value = google_kms_key_ring.ring.id }
output "gcp_key_id" { value = google_kms_crypto_key.key.id }
