resource "aws_s3_bucket" "main_bucket" {
  bucket        = local.bucket
  force_destroy = true
}

resource "aws_s3_bucket" "logging_bucket" {
  bucket        = "${local.bucket}-logs"
  force_destroy = true
}

resource "aws_s3_bucket_logging" "main_bucket_logging" {
  bucket = aws_s3_bucket.main_bucket.id

  target_bucket = aws_s3_bucket.logging_bucket.id
  target_prefix = "logs/"
}

resource "aws_s3_bucket_server_side_encryption_configuration" "main_bucket" {
  bucket = aws_s3_bucket.main_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_versioning" "main_bucket_versioning" {
  bucket = aws_s3_bucket.main_bucket.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "main_bucket_lifecycle" {
  bucket = aws_s3_bucket.main_bucket.id

  rule {
    id     = "ExpireOldVersions"
    status = "Enabled"

    noncurrent_version_expiration {
      noncurrent_days = 30
    }
  }
}

resource "aws_s3_bucket_public_access_block" "main_tf_backend_acl" {
  bucket                  = aws_s3_bucket.main_bucket.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_dynamodb_table" "state_lock" {
  name         = "state-lock"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  ttl {
    attribute_name = "ExpirationTime"
    enabled        = true
  }
}

data "aws_iam_user" "terraform_user" {
  user_name = local.terraform_user_arn
}

resource "aws_s3_bucket_policy" "main_bucket_policy" {
  bucket = aws_s3_bucket.main_bucket.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowTerraformAccess"
        Effect = "Allow"
        Principal = {
          AWS = data.aws_iam_user.terraform_user.arn
        }
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject"
        ]
        Resource = [
          "${aws_s3_bucket.main_bucket.arn}/*"
        ]
      }
    ]
  })
}

resource "aws_iam_policy" "dynamodb_lock_policy" {
  name = "dynamodb-lock-policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowTerraformLocking"
        Effect = "Allow"
        Action = [
          "dynamodb:GetItem",
          "dynamodb:PutItem",
          "dynamodb:DeleteItem",
          "dynamodb:Scan"
        ]
        Resource = "${aws_dynamodb_table.state_lock.arn}"
      }
    ]
  })
}

resource "aws_iam_user_policy_attachment" "attach_lock_policy" {
  user       = data.aws_iam_user.terraform_user.user_name
  policy_arn = aws_iam_policy.dynamodb_lock_policy.arn
}
