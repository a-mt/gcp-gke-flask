#+-------------------------------------
#| KUBERNETES
#+-------------------------------------

# Create a GKE cluster
resource "google_container_cluster" "primary" {
  name     = var.gcp_cluster_name
  project  = var.gcp_project_id
  location = "${var.gcp_region}-a"

  # To be able to clean up
  deletion_protection = false

  # Ignore changes to min-master-version as that gets changed
  # after deployment to minimum precise version Google has
  lifecycle {
    ignore_changes = [
      min_master_version,
    ]
  }

  # Timeout after 45 min if creation is still pending
  timeouts {
    create = "45m"
    update = "60m"
  }

  # Nodes
  initial_node_count = 2

  node_config {
    # https://cloud.google.com/compute/docs/general-purpose-machines
    machine_type = "n1-standard-1"

    # https://cloud.google.com/compute/docs/disks#disk-types
    disk_type    = "pd-standard"
    disk_size_gb = 10

    # https://cloud.google.com/compute/docs/access/service-accounts#default_scopes
    oauth_scopes = [
      "https://www.googleapis.com/auth/compute",
      "https://www.googleapis.com/auth/devstorage.read_only",
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
    ]
    metadata = {
      disable-legacy-endpoints = "true"
    }
    labels = {
      env = var.gcp_project_id
    }
    # Tags represent firewall rules applied to each node
    tags = [
      "gke-node",
      "gke-${var.gcp_project_id}-node",
    ]
  }
}

# Will help generate the kubeconfig file (see outputs)
module "primary_auth" {
  source       = "terraform-google-modules/kubernetes-engine/google//modules/auth"
  version      = "24.1.0"

  project_id   = google_container_cluster.primary.project
  location     = google_container_cluster.primary.location
  cluster_name = google_container_cluster.primary.name
}

# Add firewall rules
resource "google_compute_firewall" "nodeports" {
  network = "default"
  name    = "${google_container_cluster.primary.name}-nodeports-range"

  # ports 30000-32767 for potential kubernetes node ports
  # port 80 for HTTP and 443 for HTTPS
  # port 22 for SSH into the node and pod if needed
  allow {
    protocol = "tcp"
    ports    = ["30000-32767", "80", "443", "8080", "22"]
  }
  # ping any node
  allow {
    protocol = "icmp"
  }
  source_ranges = ["0.0.0.0/0"]
}


#+-------------------------------------
#| DOCKER REGISTRY
#+-------------------------------------

# Create a Docker Images repository
resource "google_artifact_registry_repository" "docker_registry" {
  repository_id = var.gcp_repo_name
  location      = var.gcp_region
  description   = "Docker repository"
  format        = "DOCKER"
}

# ---
# Create a Service account to push images
resource "google_service_account" "docker_registry_write" {
  account_id   = "${var.gcp_repo_name}-write"
  display_name = "Docker Write"
}

# Add IAM policy binding to the service account (allow to write)
resource "google_artifact_registry_repository_iam_binding" "docker_registry_write" {
  project    = google_artifact_registry_repository.docker_registry.project
  location   = google_artifact_registry_repository.docker_registry.location
  repository = google_artifact_registry_repository.docker_registry.name
  role       = "roles/artifactregistry.writer"

  members = [
    "serviceAccount:${google_service_account.docker_registry_write.email}",
  ]
}

# Create a JSON key to authenticate as this Service account
resource "google_service_account_key" "docker_registry_write_json_key" {
  service_account_id = google_service_account.docker_registry_write.name
  public_key_type    = "TYPE_X509_PEM_FILE"
}

# ---
# Add IAM policy binding to the default compute service account (allow to read)
resource "google_artifact_registry_repository_iam_binding" "docker_registry_read" {
  project    = google_artifact_registry_repository.docker_registry.project
  location   = google_artifact_registry_repository.docker_registry.location
  repository = google_artifact_registry_repository.docker_registry.name
  role       = "roles/artifactregistry.reader"

  members = [
    "serviceAccount:${var.gcp_project_number}-compute@developer.gserviceaccount.com",
  ]
}
