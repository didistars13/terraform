variable "allowed_cidr_blocks" {
  description = "List of allowed CIDR blocks for SSH access"
  type        = list(string)
}