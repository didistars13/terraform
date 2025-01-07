output "env_tfstate_bucket" {
  value = local.env_tfstate_bucket
}

output "env_state_lock_table" {
  value = aws_dynamodb_table.env_state_lock.name
}
