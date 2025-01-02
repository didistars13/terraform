data "template_file" "user_data" {
  template = file("./userdata.yaml")
}
resource "aws_instance" "my_server" {
  ami                    = local.ami
  instance_type          = local.instance_type
  key_name               = aws_key_pair.deployer.key_name
  vpc_security_group_ids = [aws_security_group.sg_my_server.id]
  user_data              = data.template_file.user_data.rendered
  provisioner "remote-exec" {
    inline = [
      "echo \"mars\" >> /home/ec2-user/barsoon/txt"
    ]
    connection {
      type        = "ssh"
      user        = "ec2-user"
      host        = self.public_ip
      private_key = file("/home/denys/.ssh/id_ed25519")
    }
  }
  tags = {
    Name = "MyServer-${local.project_name}"
  }
}
