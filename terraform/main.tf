
provider "google" {
    project = var.project_id
    region = var.region
    zone = var.zone

    credentials = file("./cred.json")
}

terraform {
    required_providers {
        google = {
            source = "hashicorp/google"
            version = "~> 6.0"
        }
    }
    backend "gcs" {
        bucket = "terraform-logging"
        prefix = "terraform/state"
        credentials = "./cred.json"
    }
}


# gcp instance
resource "google_compute_instance" "vm_instance" {
  name         = "example-instance"
  machine_type = "e2-medium"
  zone         = var.zone

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }

  network_interface {
    network       = "default"
    access_config {
      # Ephemeral public IP
      
    }
  }

  tags = ["web", "dev"]
}
