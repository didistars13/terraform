resource "aws_key_pair" "deployer" {
  key_name   = "deployer-key"
  public_key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGws2IKiELLTz0dU3d/2EZfhGOOnIEfOdc5E3fKz69N1 denys@Denys"
}