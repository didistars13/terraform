variable "env" {
  type        = string
  description = "Environment name (e.g., dev, stage, prod)"
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to all resources"
  default     = {}
}