variable "region" {
  type        = string
  description = "The AWS region to deploy resources in"
  default     = "eu-central-1"
}

variable "module_version" {
  type    = string
  default = "v1.0.0"
}