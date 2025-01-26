locals {
  env_tfstate_bucket = "${var.env}-aws328-tfstate"
  is_prod            = var.env == "prod"
}

# Env TF state bucket
resource "aws_s3_bucket" "env_tfstate_bucket" {
  bucket = local.env_tfstate_bucket

  lifecycle {
    prevent_destroy = true
  }

  tags = {
    Environment = var.env
    ManagedBy   = "Terraform"
  }
}
resource "aws_s3_bucket_public_access_block" "env_tfstate_bucket_acl" {
  bucket                  = aws_s3_bucket.env_tfstate_bucket.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_dynamodb_table" "env_state_lock" {
  name         = "${var.env}-state-lock"
  billing_mode = local.is_prod ? "PROVISIONED" : "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  lifecycle {
    prevent_destroy = true
  }

  tags = {
    Environment = var.env
    ManagedBy   = "Terraform"
  }
}