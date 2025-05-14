output "public_ip" {
  value = module.prod_ec2.instance_public_ip
}

output "instance_id" {
  value = module.prod_ec2.instance_id
}

output "vps_id" {
  value = module.prod_ec2.vpc_id
}

output "igw_id" {
  value = module.prod_ec2.igw_id
}