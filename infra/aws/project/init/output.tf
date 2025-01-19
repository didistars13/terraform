output "dynamodb_table" {
  description = "Value of dynamodb_table"
  value       = resource.aws_dynamodb_table.state_lock.name
}

output "main_bucket" {
  description = "Value of main_bucket"
  value       = aws_s3_bucket.main_bucket.bucket
}

output "force_destroy" {
  description = "Value of force_destroy"
  value       = aws_s3_bucket.main_bucket.force_destroy
}

output "bucket_names" {
  description = "The names of the S3 buckets in each environment"
  value       = { for env, module in local.environments : env => module.env_tfstate_bucket }
}

output "state_lock_tables" {
  description = "The names of the DynamoDB tables in each environment"
  value       = { for env, module in local.environment_map : env => module.env_state_lock_table }
}