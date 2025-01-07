provider "aws" {
  region = var.region
}

data "template_file" "user_data" {
  template = file("./userdata.yaml")
}

resource "aws_key_pair" "deployer_key" {
  key_name   = var.key_name
  public_key = var.public_key
}

resource "aws_instance" "my_server" {
  ami                         = var.ami
  instance_type               = var.instance_type
  key_name                    = aws_key_pair.deployer_key.key_name
  vpc_security_group_ids      = [aws_security_group.default.id]
  subnet_id                   = module.vpc.public_subnets[0]
  associate_public_ip_address = true
  user_data                   = data.template_file.user_data.rendered
  connection {
    type        = "ssh"
    user        = "ec2-user"
    host        = self.public_ip
    private_key = file(var.private_key)
  }
  provisioner "remote-exec" {
    inline = [
      "echo \"mars\" >> /home/ec2-user/test.txt"
    ]
  }
  tags = {
    Name = var.instance_name
  }
}
