
#+-------------------------------------
#| KUBERNETES
#+-------------------------------------

output "gke_kubeconfig" {
  value       = module.primary_auth.kubeconfig_raw
  description = "Credentials to connect to the cluster"
  sensitive   = true
}

# You can find it as "clusters.0.name" in the kubeconfig
output "gke_cluster_name" {
  value       = "${google_container_cluster.primary.name}"
  sensitive   = false
}

# You can find it as "clusters.0.cluster.server" in the kubeconfig
output "gke_cluster_ip" {
  value       = "${google_container_cluster.primary.endpoint}"
  sensitive   = false
}

#+-------------------------------------
#| DOCKER REGISTRY
#+-------------------------------------

locals {
  docker_registry_repository_region   = google_artifact_registry_repository.docker_registry.location
  docker_registry_repository_project  = google_artifact_registry_repository.docker_registry.project
  docker_registry_repository_name     = google_artifact_registry_repository.docker_registry.name
  docker_registry_repository_hostname = "${local.docker_registry_repository_region}-docker.pkg.dev"
}

# ${REGION}-docker.pkg.dev
output "docker_registry_hostname" {
  value        = local.docker_registry_repository_hostname
  description  = "Hostname of the Docker registry"
  sensitive    = false
}

# ${REGION}-docker.pkg.dev/${PROJECT_ID}/${REPO_NAME}
output "docker_registry_repository_url" {
  value        = "${local.docker_registry_repository_hostname}/${local.docker_registry_repository_project}/${local.docker_registry_repository_name}"
  sensitive    = false
}

output "docker_registry_write_json_key" {
  value        = google_service_account_key.docker_registry_write_json_key.private_key
  description  = "Credentials to push to the Docker registry"
  sensitive    = true
}
