module "dev_ec2" {
  source          = "../../../../modules/aws"
  ami             = local.ami
  azs             = local.azs
  env             = local.env
  instance_type   = local.instance_type
  instance_name   = local.instance_name
  key_name        = local.key_name
  my_ip           = var.my_ip
  private_key     = local.private_key
  private_subnets = local.private_subnets
  public_key      = local.public_key
  public_subnets  = local.public_subnets
  region          = local.region
  user_data       = local.user_data
  vpc_cidr        = local.vpc_cidr
  vpc_name        = local.vpc_name
  tags = {
    Environment = "dev"
  }
}
