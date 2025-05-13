locals {
  env           = "dev" # Change this to the appropriate environment (e.g., "dev", "prod")
  az            = "eu-central-1a"
  instance_name = "${local.env}_instance"
  instance_type = "t2.micro"
  key_name      = "${local.env}_deployer"
  private_key   = "~/.ssh/dev_deployer"
  public_subnet = "10.0.101.0/24"
  public_key    = file("~/.ssh/dev_deployer.pub")
  region        = "eu-central-1"
  vpc_cidr      = "10.0.0.0/16"
  vpc_name      = "${local.env}_vpc"
}
