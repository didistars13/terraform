module "dev" {
  source = "../../../../modules/aws/workload"
  env    = "dev"
}

module "stage" {
  source = "../../../../modules/aws/workload"
  env    = "stage"
}
