module "vpc" {
  source          = "terraform-aws-modules/vpc/aws"
  name            = var.vpc_name
  cidr            = var.vpc_cidr
  azs             = var.azs
  private_subnets = var.private_subnets
  public_subnets  = var.private_subnets

  enable_nat_gateway = true
  enable_vpn_gateway = true

  tags = {
    Name      = var.vpc_name
    Terraform = "true"
  }
}
