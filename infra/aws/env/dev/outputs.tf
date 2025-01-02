output "public_ip" {
  value = aws_instance.my_server.public_ip
}
output "instance_id" {
  value = aws_instance.my_server.id
}
output "instance_tags" {
  value = aws_instance.my_server.tags_all
}
output "vps_id" {
  value = module.vpc.vpc_id
}
output "gw_id" {
  value = module.vpc.igw_id
}