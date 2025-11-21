# Secret Manager 

data "google_secret_manager_secret_version" "cred" {
  project = var.project_id
  secret  = "cred"
}

# VPC NETWORK

resource "google_compute_network" "vpc" {
  name                    = "poc${var.project_id}-vpc01"
  auto_create_subnetworks = false
}


# PUBLIC SUBNET

resource "google_compute_subnetwork" "public_subnet" {
  name          = "public-subnet"
  region        = var.region
  network       = google_compute_network.vpc.id
  ip_cidr_range = "10.10.1.0/24"

  # Allow public IPs
  private_ip_google_access = false
}

# PRIVATE SUBNET

resource "google_compute_subnetwork" "private_subnet" {
  name          = "private-subnet"
  region        = var.region
  network       = google_compute_network.vpc.id
  ip_cidr_range = "10.10.2.0/24"

  # No public IP, but allow Google API access
  private_ip_google_access = true
}

# CLOUD ROUTER (required for NAT)

resource "google_compute_router" "router" {
  name    = "vpc-router"
  region  = var.region
  network = google_compute_network.vpc.id
}

# CLOUD NAT – for PRIVATE subnet internet

resource "google_compute_router_nat" "nat" {
  name                               = "vpc-nat"
  router                             = google_compute_router.router.name
  region                             = var.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "LIST_OF_SUBNETWORKS"

  subnetwork {
    name                    = google_compute_subnetwork.private_subnet.id
    source_ip_ranges_to_nat = ["ALL_IP_RANGES"]
  }
}

# UPDATED VM INSTANCE (to use PUBLIC subnet)
resource "google_compute_instance" "vm_instance" {
  name         = "test-vm01"
  machine_type = "e2-medium"
  zone         = var.zone

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.public_subnet.id

    # Public IP
    access_config {}
  }

  tags = ["web", "dev"]
}













