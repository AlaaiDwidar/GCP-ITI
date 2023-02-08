

#service-account
resource "google_service_account" "sa" {
  account_id   = "gke-cluster-nodes"
  display_name = "GKE-sa"
}

#roles-of-service-account
resource "google_project_iam_binding" "sa-binding" {
project = "bamboo-autumn-375708"
role =  "roles/container.admin"
members = [
  "serviceAccount:${google_service_account.sa.email}"
]
}

#cluster
resource "google_container_cluster" "private-cluster" {
  name                     = "alaa-cluster"
  location                 = "us-central1-a"
  remove_default_node_pool = true
  initial_node_count       = 1
  network                  = google_compute_network.vpc_network.self_link
  subnetwork = google_compute_subnetwork.Restricted-Subnet.self_link

  addons_config {
    http_load_balancing {
      disabled = true
    }
  }

 release_channel {
    channel = "REGULAR"
  }

 ip_allocation_policy {
    
  }

  private_cluster_config {
    
    enable_private_nodes    = true   
    enable_private_endpoint = true
    master_ipv4_cidr_block  = "172.16.0.0/28" 

  }

  master_authorized_networks_config {
    cidr_blocks {
      cidr_block = "10.0.0.0/16"
      
    }
  }
}

#service-account-vm
resource "google_service_account" "vm-sa" {
  account_id   = "vm-service-account"
  display_name = "my-service-account"
}

#service-account-vm-role
resource "google_project_iam_binding" "vm-sa-binding" {
project = "bamboo-autumn-375708"
role =  "roles/storage.objectViewer"
members = [
  "serviceAccount:${google_service_account.vm-sa.email}"
]
}


#cluster node pool
resource "google_container_node_pool" "private-cluster-nodes" {
  name       = "node-pool"
  cluster    = google_container_cluster.private-cluster.id
  location   = "us-central1-a"
  node_count = 1

  node_config {
    preemptible  = true 
    machine_type = "e2-medium"
    # service_account = google_service_account.vm-sa.email
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
  }
}