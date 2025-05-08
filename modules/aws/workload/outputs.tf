output "env_tfstate_bucket" {
  value = aws_s3_bucket.env_tfstate_bucket.id
}

output "env_state_lock_table" {
  description = "Name of the DynamoDB table used for state locking"
  value       = local.is_prod ? aws_dynamodb_table.env_state_lock_provisioned[0].name : aws_dynamodb_table.env_state_lock_on_demand[0].name
}

output "group_name" {
  value = aws_iam_group.group.name
}