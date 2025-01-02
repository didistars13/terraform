locals {
  project_name  = "Denys"
  ami           = "ami-0e54671bdf3c8ed8d"
  region        = "eu-central-1"
  key           = "network/terraform.tfstate"
  aws_s3_bucket = "my_teffarorm_test_didistars328"
  instance_type = "t2.micro"
  azs           = ["eu-central-1a", "eu-central-1b", "eu-central-1c"]
}