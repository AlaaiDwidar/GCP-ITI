

#vpc
resource "google_compute_network" "vpc_network" {
  name                    = "alaa-vpc"
  auto_create_subnetworks = false
}
#subnets
resource "google_compute_subnetwork" "Management-Subnet" {
  name          = "management-subnet"
  ip_cidr_range = "10.0.0.0/16"
  region        = "us-central1"
  network       = google_compute_network.vpc_network.self_link
}

resource "google_compute_subnetwork" "Restricted-Subnet" {
  name                     = "restricted-subnet"
  ip_cidr_range            = "10.1.0.0/16"
  region                   = "us-central1"
  network                  = google_compute_network.vpc_network.self_link
  private_ip_google_access = true
}

#natgway
resource "google_compute_router" "router" {
  name    = "my-router"
  region  = google_compute_subnetwork.Management-Subnet.region
  network = google_compute_network.vpc_network.self_link
}

resource "google_compute_router_nat" "nat" {
  name                               = "my-router-nat"
  router                             = google_compute_router.router.name
  region                             = google_compute_router.router.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "LIST_OF_SUBNETWORKS"
  subnetwork {
    name                    = google_compute_subnetwork.Management-Subnet.id
    source_ip_ranges_to_nat = ["ALL_IP_RANGES"]
  }
}
#firewall

resource "google_compute_firewall" "allow-ssh" {
  name    = "my-firewall-cluster"
  network = google_compute_network.vpc_network.self_link
  # target_tags = ["vm"]

  allow {
    protocol = "tcp"
    ports    = ["22","80"]
  }
  target_service_accounts = [google_service_account.sa.email]
  source_ranges = ["0.0.0.0/0"]
  direction = "INGRESS"

}