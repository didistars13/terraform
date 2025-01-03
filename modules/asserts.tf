# We have to ensure that ORG module ("project") has a corresponding
# record for this account (environment).

data "terraform_remote_state" "org" {
  backend = "s3"
  config = {
    bucket = var.org_tfstate_bucket
    key    = var.org_tfstate_key
    region = var.org_tfstate_region
  }
}

locals {
  org_account_info = lookup(data.terraform_remote_state.org.outputs.env_accounts, var.aws_account, null)
}

data "assert_test" "org_has_env_account" {
  test  = local.org_account_info != null
  throw = "ORG has no info about this account"
}

data "assert_test" "env_names_match" {
  test  = local.org_account_info["env"] == var.env
  throw = "ORG env and this env names do not match"
}

data "assert_test" "eks_requires_vpc" {
  test  = (var.create_eks == false) || (var.create_eks && var.create_vpc)
  throw = "EKS requires a VPC, please set create_vpc to true"
}
