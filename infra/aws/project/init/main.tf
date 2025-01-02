terraform {
  backend "local" {
    path = "terraform.tfstate"
  }
}

resource "aws_s3_bucket" "main_bucket" {
  bucket = local.bucket
}

resource "aws_dynamodb_table" "state_lock" {
  name         = "state-lock"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}

output "dynamodb_table" {
  value = resource.aws_dynamodb_table.state_lock.name
}

output "bucket_name" {
  value = aws_s3_bucket.main_bucket.bucket
}
