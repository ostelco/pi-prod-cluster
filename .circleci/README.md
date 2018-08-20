# .Circleci config

The config is **almost** identical to the one used for the `DEV` cluster in the [`DEV`cluster repo](https://github.com/ostelco/infra)

# The docker image

The Terraform docker image used in the pipeline is used from the Google container registry in the `Pi-Dev` project. The dockerfile and the docker-entrypoint script can be found [here](https://github.com/ostelco/infra/tree/master/.circleci).