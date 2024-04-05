
#+-------------------------------------
#| AUTHORIZATION
#+-------------------------------------

# Credentials
variable "gcp_credentials" {
  type        = string
  description = "Credentials (JSON key content without newlines)"
}
variable "gcp_project_id" {
  type        = string
  description = "Project ID — test-django-419014"
}
variable "gcp_region" {
  type        = string
  description = "Default region to manage resources"
  default     = "us-west1"
}

# Project
variable "gcp_project_name" {
  type        = string
  description = "Project name — test-django"
}
variable "gcp_project_number" {
  type        = string
  description = "Project number — 8575900557"
}

#+-------------------------------------
#| PREFERENCES
#+-------------------------------------

# Kubernetes cluster
variable "gcp_cluster_name" {
  type        = string
  description = "Kubernetes cluster ID"
  default     = "test-gke-2"
}

# Docker registry
variable "gcp_repo_name" {
  type        = string
  description = "Docker registry ID"
  default     = "test-gke-repo-2"
}
