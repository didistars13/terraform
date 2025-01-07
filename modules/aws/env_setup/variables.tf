variable "ami" {
  description = "AMI ID for the EC2 instance"
  type        = string
}
variable "azs" {
  description = "Availability zones to deploy the instance in"
  type        = list(string)
}

variable "env" {
  description = "Environment to deploy the instance in"
  type        = string
}

variable "instance_name" {
  description = "Name of the EC2 instance"
  type        = string
}

variable "instance_type" {
  description = "Instance type for the EC2 instance"
  type        = string
  default     = "t2.micro"
}

variable "key_name" {
  description = "Name of the SSH key to use for the instance"
  type        = string
}

variable "allowed_cidr_blocks" {
  description = "List of allowed CIDR blocks for SSH access"
  type        = list(string)
}

variable "private_key" {
  description = "Path to the private key to use for the instance"
  type        = string
}

variable "private_subnets" {
  description = "CIDR blocks for the private subnets"
  type        = list(string)
}

variable "public_subnets" {
  description = "CIDR blocks for the public subnets"
  type        = list(string)
}

variable "public_key" {
  description = "Path to the public key to use for the instance"
  type        = string
}

variable "region" {
  description = "The AWS region to deploy resources in"
  type        = string
  default     = "eu-central-1"
}

variable "vpc_name" {
  description = "Name of the VPC to deploy the instance in"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "user_data" {
  description = "Path to the user data script to use for the instance"
  type        = string
}

variable "tags" {
  description = "Tags to apply to the instance"
  type        = map(string)
  default     = {}
}
