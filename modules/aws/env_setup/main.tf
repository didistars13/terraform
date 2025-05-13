provider "aws" {
  region = var.region
}

resource "aws_key_pair" "deployer_key" {
  key_name   = var.key_name
  public_key = var.public_key
}

data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*"]
  }
}

resource "aws_instance" "my_server" {
  ami                         = data.aws_ami.amazon_linux.id
  instance_type               = var.instance_type
  key_name                    = aws_key_pair.deployer_key.key_name
  vpc_security_group_ids      = [aws_security_group.default.id]
  subnet_id                   = aws_subnet.public.id
  associate_public_ip_address = true
  user_data                   = file("${path.module}/userdata.sh")

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
