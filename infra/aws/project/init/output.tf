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

output "dev_bucket_name" {
  description = "The name of the S3 bucket in the dev environment"
  value       = module.dev.env_tfstate_bucket
}

output "dev_state_lock_table" {
  description = "The name of the DynamoDB table in the dev environment"
  value       = module.dev.env_state_lock_table
}