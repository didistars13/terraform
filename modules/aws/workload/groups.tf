resource "aws_iam_group" "group" {
  name = "${var.env}-group"

  #depends_on = [aws_s3_bucket.env_tfstate_bucket]
}
