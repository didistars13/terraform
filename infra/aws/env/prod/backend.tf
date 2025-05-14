terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  # S3 backet and dynamodb table name have to be takedn from the output of the init project
  backend "s3" {
    bucket         = "prod-aws328-tfstate"
    key            = "terraform.tfstate"
    region         = "eu-central-1"
    dynamodb_table = "prod-state-lock"
    encrypt        = true
  }
}