terraform {
  backend "s3" {
    bucket         = "test-aws328-tfstate"
    key            = "terraform.tfstate"
    region         = "eu-central-1"
    dynamodb_table = "state-lock"
  }
}
