
variable "project_id" {
  description = "Google Cloud project ID."
  default = "pi-ostelco-prod"
}

variable "regional" {
  description = "whether the cluster should be created in multiple zones or not."
  default = false
}

variable "cluster_region" {
  default     = "europe-west1"
  description = "The region where the cluster will be created."
}

variable "cluster_zones" {
  default     = ["europe-west1-c"]
  description = "The zone(s) where the cluster will be created."
}

variable "cluster_admin_password" {
  description = "password for cluster admin. Must be 16 characters at least."
}

# Configure the Google Cloud provider
provider "google-beta" {
  project = "${var.project_id}"
  region  = "${var.cluster_region}"
}

module "gke" {
  source              = "github.com/ostelco/ostelco-terraform-modules//terraform-google-gke-cluster"
  project_id            = "${var.project_id}"
  cluster_password      = "${var.cluster_admin_password}"
  cluster_name          = "pi-prod"
  cluster_description   = "Production cluster for Ostelco Pi."
  cluster_version       = "1.11.8-gke.4"
  cluster_zones         = "${var.cluster_zones}"
  regional              = "${var.regional}"

}

module "high-mem" {
  source         = "github.com/ostelco/ostelco-terraform-modules//terraform-google-gke-node-pool"
  project_id     = "${var.project_id}"
  regional       = "${var.regional}"
  cluster_name   = "${module.gke.cluster_name}" # creates implicit dependency
  cluster_region = "${var.cluster_region}"
  node_pool_zone = "${var.cluster_zones[0]}"

  node_pool_name = "highmem-pool"
  pool_min_node_count    = "2"
  initial_node_pool_size = "3"
  pool_max_node_count    = "6"
  node_tags              = ["high-mem"]
  auto_upgrade           = true
  pool_node_machine_type = "n1-standard-4"

  node_labels = {
    "env"         = "high-mem"
    "machineType" = "n1-highmem-2"
  }
  
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
      "https://www.googleapis.com/auth/ndev.clouddns.readwrite", 
      "https://www.googleapis.com/auth/servicecontrol",
    ]


}

resource "google_compute_address" "static_ambassador_ip" {
  provider = "google-beta"
  name = "ambassador-static-ip"
  description = "A static external IP for prod Ambassador LB"
}

output "prod_cluster_ambassador_ip" {
  sensitive = true
  value = "${google_compute_address.static_ambassador_ip.address}"
}


output "prod_cluster_endpoint" {
  sensitive = true
  value = "${module.gke.cluster_endpoint}"
}

output "prod_cluster_client_certificate" {
  sensitive = true
  value = "${module.gke.cluster_client_certificate}"
}

output "prod_cluster_client_key" {
  sensitive = true
  value = "${module.gke.cluster_client_key}"
}

output "prod_cluster_ca_certificate" {
  sensitive = true
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
