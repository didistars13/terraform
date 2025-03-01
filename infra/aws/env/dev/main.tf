module "dev_ec2" {
  source              = "git::https://github.com/didistars13/terraform.git//modules/aws/env_setup?ref=v1.0.0"
  azs                 = local.azs
  env                 = local.env
  instance_type       = local.instance_type
  instance_name       = local.instance_name
  key_name            = local.key_name
  allowed_cidr_blocks = var.allowed_cidr_blocks
  private_key         = local.private_key
  private_subnets     = local.private_subnets
  public_key          = local.public_key
  public_subnets      = local.public_subnets
  region              = local.region
  vpc_cidr            = local.vpc_cidr
  vpc_name            = local.vpc_name
  tags = {
    Environment = local.env
  }
}
