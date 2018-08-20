# Terraform scripts

## Terraform Modules

The Terraform scripts in this repo use Terraform modules to create the **PROD** cluster. The two modules used are:

- [terraform-google-gke-cluster](https://github.com/ostelco/ostelco-terraform-modules/tree/master/terraform-google-gke-cluster) : launches a cluster and deletes its default node pool.
- [terraform-google-gke-node-pool](https://github.com/ostelco/ostelco-terraform-modules/tree/master/terraform-google-gke-node-pool) :  launches new node pools and associate them to existing clusters.

An [example](https://github.com/ostelco/ostelco-terraform-modules/blob/master/example/main.tf) of using the modules together is available. The input variables for each of the modules are listed in their README files ([cluster](https://github.com/ostelco/ostelco-terraform-modules/tree/master/terraform-google-gke-cluster) , [node pools](https://github.com/ostelco/ostelco-terraform-modules/tree/master/terraform-google-gke-node-pool)). 

## Terraform scripts

The **PROD** cluster terraform config is available in the `master`branch in a file called `prod-cluster.tf`. 

> The TF file name can be changed to anything else. It also can be split to multiple files (e.g, variables.tf & outputs.tf & main.tf)

## Terraform state

The terraform state files are stored in Google buckets. 

- For the **PROD** cluster: it is stored in a bucket called: `pi-ostelco-prod-terraform-state` in the `pi-ostelco-prod` project.

