# Google GKE PROD cluster

[![CircleCI](https://circleci.com/gh/ostelco/pi-prod-cluster.svg?style=svg&circle-token=7dd15473a94c628bc5c1e8f092e0216371ffba85)](https://circleci.com/gh/ostelco/pi-prod-cluster)

Terraform config and Circleci pipeline to build and maintain Kubernetes Production cluster.

## Pipeline docs

The following docs are available:
- [circleci-pipeline](docs/circleci-pipeline.md)
- [terraform-scripts](docs/terraform-scripts.md)


## Notes:

- The Circleci pipeline runs a plan step, waits for human approval before it applies changes.
- Some changes may cause a cluster recreation. **Inspect** the plan step results before you approve applying the changes.
- While the Terraform config can be run from any machine. It's **strongly discouraged** to do so to avoid Terraform state file locking. 
