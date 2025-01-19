output "env_tfstate_bucket" {
  value = aws_s3_bucket.env_tfstate_bucket.id
}

output "env_state_lock_table" {
  value = aws_dynamodb_table.env_state_lock.name
}
