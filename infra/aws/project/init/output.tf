output "dynamodb_table" {
  value = resource.aws_dynamodb_table.state_lock.name
}

output "bucket_name" {
  value = aws_s3_bucket.main_bucket.bucket
}

output "force_destroy" {
  value = aws_s3_bucket.main_bucket.force_destroy
}