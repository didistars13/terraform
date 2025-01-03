module "dev_ec2" {
  source        = "../../project/shared"
  instance_name = "dev-instance"
  instance_type = local.instance_type
  ami           = local.ami
  tags = {
    Environment = "dev"
  }
}
