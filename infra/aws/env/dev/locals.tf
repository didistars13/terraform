locals {
  env             = "dev"
  ami             = "ami-0e54671bdf3c8ed8d"
  azs             = ["eu-central-1a", "eu-central-1b", "eu-central-1c"]
  instance_name   = "${local.env}_instance"
  instance_type   = "t2.micro"
  key_name        = "${local.env}_deployer"
  private_key     = "~/.ssh/dev_deployer"
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
  public_key      = file("~/.ssh/dev_deployer.pub")
  region          = "eu-central-1"
  user_data       = file("./userdata.yaml")
  vpc_cidr        = "10.0.0.0/16"
  vpc_name        = "${local.env}_vpc"
}
