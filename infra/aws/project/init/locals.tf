locals {
  bucket = "init-aws328-tfstate"
  environments = [
    "dev",
    "stage",
    "prod",
  ]
  environment_map    = { for env in local.environments : env => module.workloads[env] }
  terraform_user_arn = "terraform"
}