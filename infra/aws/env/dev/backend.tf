terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    bucket         = data.terraform_remote_state.org.outputs.org_tfstate_bucket
    key            = data.terraform_remote_state.org.outputs.org_tfstate_key
    region         = data.terraform_remote_state.org.outputs.org_tfstate_region
    dynamodb_table = data.terraform_remote_state.org.outputs.org_tfstate_table
    encrypt        = data.terraform_remote_state.org.outputs.org_tfstate_encryption
  }
}

data "terraform_remote_state" "org" {
  backend = "s3"
  config = {
    bucket = "test-aws328-tfstate"
    key    = "terraform.tfstate"
    region = local.region
  }
}