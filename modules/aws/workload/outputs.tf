output "env_tfstate_bucket" {
  value = aws_s3_bucket.env_tfstate_bucket.id
}

output "env_state_lock_table" {
  description = "Name of the DynamoDB table used for state locking"
  value       = aws_dynamodb_table.env_state_lock.name
}

output "group_name" {
  value = aws_iam_group.group.name
}