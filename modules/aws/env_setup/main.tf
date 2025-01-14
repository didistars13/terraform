provider "aws" {
  region = var.region
}

resource "aws_key_pair" "deployer_key" {
  key_name   = var.key_name
  public_key = var.public_key
}

resource "aws_iam_instance_profile" "ec2_instance_profile" {
  name = "${var.env}-ec2-instance-profile"
  role = aws_iam_role.ec2_role.name
}

resource "aws_instance" "my_server" {
  ami                         = var.ami
  instance_type               = var.instance_type
  key_name                    = aws_key_pair.deployer_key.key_name
  vpc_security_group_ids      = [aws_security_group.default.id]
  subnet_id                   = module.vpc.public_subnets[0]
  associate_public_ip_address = true
  user_data                   = file("${path.module}/userdata.sh")
  iam_instance_profile        = aws_iam_instance_profile.ec2_instance_profile.name

  tags = {
    Name = var.instance_name
  }
}

resource "null_resource" "status_check" {
  triggers = {
    instance_id = aws_instance.my_server.id
  }
  provisioner "local-exec" {
    command = "aws ec2 wait instance-status-ok --instance-ids ${aws_instance.my_server.id}"
  }
}
