# terraform {
#   backend "local" {
#     path = "terraform.tfstate"
#   }
# }

resource "aws_s3_bucket" "main_bucket" {
  bucket        = local.bucket
  force_destroy = true
}

resource "aws_s3_bucket_versioning" "main_bucket_versioning" {
  bucket = aws_s3_bucket.main_bucket.id

  versioning_configuration {
    status = "Enabled"
  }
}

# resource "aws_s3_object" "objects" {
#   for_each = {
#     "tfstate" = "terraform.tfstate"
#     # Add more objects as needed
#   }
#   bucket = aws_s3_bucket.main_bucket.bucket
#   key    = each.key
#   source = each.value

#   lifecycle {
#     prevent_destroy = false
#   }
# }

resource "aws_dynamodb_table" "state_lock" {
  name         = "state-lock"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}
