resource "aws_s3_bucket" "logging" {
  acl    = "private"
}

resource "aws_s3_bucket" "example_2" {
  acl    = "private"
}

resource "aws_s3_bucket" "example" {
  acl    = "private"
  logging {
    target_bucket = aws_s3_bucket.logging.id
    target_prefix = "log/"
  }
}

resource "aws_s3_bucket_logging" "example" {
  bucket = aws_s3_bucket.example_2.id

  target_bucket = aws_s3_bucket.logging.id
  target_prefix = "log/"
}

resource "aws_s3_bucket_public_access_block" "example" {
  bucket = aws_s3_bucket.example.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_policy" "allow_access_from_another_account" {
  bucket = aws_s3_bucket.example.id
  policy = data.aws_iam_policy_document.allow_access_from_another_account.json
}

data "aws_iam_policy_document" "allow_access_from_another_account" {
  statement {
    principals {
      type        = "AWS"
      identifiers = [data.aws_caller_identity.current.account_id]
    }

    actions = [
      "s3:GetObject",
      "s3:ListBucket",
    ]

    resources = [
      aws_s3_bucket.example.arn,
      "${aws_s3_bucket.example.arn}/*",
    ]
  }
}

data "aws_caller_identity" "current" {}

resource "aws_s3_account_public_access_block" "example" {
  block_public_acls   = true
  block_public_policy = true
}
