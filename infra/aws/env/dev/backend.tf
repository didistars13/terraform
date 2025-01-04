resource "aws_s3_bucket" "main_bucket" {
  bucket        = "dev-terraform-state-lock"
  force_destroy = true
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    bucket         = "dev_aws328_tfstate"
    key            = "dev/terraform.tfstate"
    region         = "eu-central-1"
    dynamodb_table = "dev-terraform-state-lock"
    encrypt        = true
  }
}