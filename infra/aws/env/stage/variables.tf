variable "allowed_cidr_blocks" {
  description = "List of allowed CIDR blocks for SSH access"
  type        = list(string)
}

variable "public_key" {
  description = "SSH public key"
  type        = string
}

variable "private_key" {
  description = "SSH private key (used locally for connections, not in cloud resources)"
  type        = string
}