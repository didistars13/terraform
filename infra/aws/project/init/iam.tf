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
