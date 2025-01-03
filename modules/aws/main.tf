data "aws_region" "current" {}

data "aws_availability_zones" "available" {}

locals {
  # No matter how many availability zones we have in a particular
  # region, we allocate resources in the first three zones:
  az_names = slice(data.aws_availability_zones.available.names, 0, 3)
  region   = data.aws_region.current.name
  public_subnets = [
    for az in local.az_names : cidrsubnet(
      cidrsubnet(var.region_cidr, 2, 0),
      4,
    index(local.az_names, az))
  ]
  private_subnets = [
    for az in local.az_names : cidrsubnet(
      var.region_cidr,
      2,
    index(local.az_names, az) + 1)
  ]
  common_tags = merge(var.common_tags, { "env" = var.env })
}

# https://github.com/terraform-aws-modules/terraform-aws-vpc/
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "3.14.0"

  create_vpc = var.create_vpc
  name       = "main-vpc"
  cidr       = var.region_cidr

  azs             = local.az_names
  public_subnets  = local.public_subnets
  private_subnets = local.private_subnets

  enable_nat_gateway = true
  single_nat_gateway = false

  tags = local.common_tags
}

# https://github.com/terraform-aws-modules/terraform-aws-eks/
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 18.0"

  cluster_name    = "${var.env}-eks-cluster"
  cluster_version = "1.22"
  create          = var.create_eks

  # EKS private cluster
  cluster_endpoint_public_access  = false
  cluster_endpoint_private_access = true

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  eks_managed_node_groups = var.eks_node_pools

  cluster_security_group_additional_rules = {
    ingress_permit_https = {
      description = "EKS Control plane access from within VPC"
      protocol    = "tcp"
      from_port   = 443
      to_port     = 443
      type        = "ingress"
      cidr_blocks = ["${module.vpc.vpc_cidr_block}"]
    }
  }

  node_security_group_additional_rules = {
    ingress_permit_main_vpc = {
      description = "Permits ingress connection within this cluster"
      protocol    = "-1" # Any protocol (tcp, udp, icmp, ...)
      from_port   = -1
      to_port     = -1
      type        = "ingress"
      cidr_blocks = ["${module.vpc.vpc_cidr_block}"]
    }
    eggress_permit_all = {
      description = "Permits outgoing connection to any destination"
      protocol    = "-1" # Any protocol (tcp, udp, icmp, ...)
      from_port   = -1
      to_port     = -1
      type        = "egress"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  tags = local.common_tags
}

