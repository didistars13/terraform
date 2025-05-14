module "prod_ec2" {
  source = "git::https://github.com/didistars13/terraform.git//modules/aws/env_setup?ref=v1.0.7"
  #source              = "../../../../modules/aws/env_setup"
  az                  = local.az
  env                 = local.env
  instance_type       = local.instance_type
  instance_name       = local.instance_name
  key_name            = local.key_name
  allowed_cidr_blocks = var.allowed_cidr_blocks
  private_key         = var.private_key
  public_key          = var.public_key
  public_subnet       = local.public_subnet
  region              = local.region
  vpc_cidr            = local.vpc_cidr
  vpc_name            = local.vpc_name
  tags = {
    Environment = local.env
  }
}
