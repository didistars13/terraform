output "instance_id" {
  value = aws_instance.my_server.id
}

output "instance_public_ip" {
  value = aws_instance.my_server.public_ip
}

output "vpc_id" {
  value = module.vpc.vpc_id
}

output "igw_id" {
  value = module.vpc.igw_id
}