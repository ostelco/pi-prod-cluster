variable "project_name" {
  description = "Google Cloud project ID."
  default     = "pi-ostelco-prod"
}

variable "cluster_region" {
  default     = "europe-west1"
  description = "The region where the cluster will be created."
}

variable "cluster_zone" {
  default     = "europe-west1-c"
  description = "The zone where the cluster will be created."
}

variable "cluster_admin_password" {
  description = "password for cluster admin. Must be 16 characters at least."
}

# Configure the Google Cloud provider
provider "google" {
  project = "${var.project_name}"
  region  = "${var.cluster_region}"
}

module "gke" {
  source              = "github.com/ostelco/ostelco-terraform-modules//terraform-google-gke-cluster"
  cluster_password    = "${var.cluster_admin_password}"
  cluster_name        = "pi-prod"
  cluster_description = "Production cluster for Ostelco Pi."
  cluster_version     = "1.9.7-gke.6"
  cluster_zone        = "${var.cluster_zone}"

  # the line below makes the cluster multizone (regional)
  #cluster_additional_zones = ["europe-west1-b"]
}

module "np" {
  source         = "github.com/ostelco/ostelco-terraform-modules//terraform-google-gke-node-pool"
  cluster_name   = "${module.gke.cluster_name}"
  node_pool_zone = "${module.gke.cluster_zone}"

  node_pool_name         = "small-nodes-pool"
  node_count             = "2"
  pool_min_node_count    = "1"
  pool_max_node_count    = "4"
  node_tags              = ["prod"]

  # oauth_scopes define what Google API nodes in the pool have access to.
  # list of APIs can be found here: https://developers.google.com/identity/protocols/googlescopes
  oauth_scopes = [
      "https://www.googleapis.com/auth/compute",
      "https://www.googleapis.com/auth/devstorage.read_write",
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
      "https://www.googleapis.com/auth/service.management",
      "https://www.googleapis.com/auth/pubsub",
      "https://www.googleapis.com/auth/datastore",
      "https://www.googleapis.com/auth/bigquery",
      "https://www.googleapis.com/auth/sqlservice.admin",
    ]

  node_labels = {
    "env"         = "prod"
    "machineType" = "n1-standard-1"
  }
}


output "prod_cluster_endpoint" {
  value = "${module.gke.cluster_endpoint}"
}

output "prod_cluster_client_certificate" {
  value = "${module.gke.cluster_client_certificate}"
}

output "prod_cluster_client_key" {
  value = "${module.gke.cluster_client_key}"
}

output "prod_cluster_ca_certificate" {
  value = "${module.gke.cluster_ca_certificate}"
}

# the backend config for storing terraform state in GCS 
# requires setting GOOGLE_CREDNETIALS to contain the path to your Google Cloud service account json key.
terraform {
  backend "gcs" {
    bucket = "pi-ostelco-prod-terraform-state"
    prefix = "clusters/prod/state"
  }
}
