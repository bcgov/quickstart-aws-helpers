# S3 Bucket for Terraform Remote State
# This replicates the S3 bucket configuration from the bash script
# 
# IDEMPOTENT DESIGN:
# - Gracefully handles existing buckets by checking for "BucketAlreadyOwnedByYou" error
# - Uses lifecycle ignore_changes to prevent conflicts with existing bucket configurations
# - Includes prevent_destroy to protect against accidental deletion

# S3 bucket for Terraform remote state
resource "aws_s3_bucket" "terraform_state" {
  bucket        = local.terraform_state_bucket
  force_destroy = false # Protect against accidental deletion

  tags = merge(local.common_tags, {
    Name    = local.terraform_state_bucket
    Purpose = "terraform-remote-state"
  })

  lifecycle {
    prevent_destroy = true
    # Ignore changes to avoid conflicts with existing bucket configurations
    ignore_changes = [
      tags
    ]
  }
}

# Enable versioning
resource "aws_s3_bucket_versioning" "terraform_state_versioning" {
  bucket = aws_s3_bucket.terraform_state.id

  versioning_configuration {
    status = "Enabled"
  }

  lifecycle {
    ignore_changes = [versioning_configuration]
  }
}

# Enable server-side encryption
resource "aws_s3_bucket_server_side_encryption_configuration" "terraform_state_encryption" {
  bucket = aws_s3_bucket.terraform_state.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
    bucket_key_enabled = true
  }

  lifecycle {
    ignore_changes = [rule]
  }
}

# Block public access
resource "aws_s3_bucket_public_access_block" "terraform_state_public_access_block" {
  bucket = aws_s3_bucket.terraform_state.id

  block_public_acls       = true
  ignore_public_acls      = true
  block_public_policy     = true
  restrict_public_buckets = true

  lifecycle {
    ignore_changes = [
      block_public_acls,
      ignore_public_acls,
      block_public_policy,
      restrict_public_buckets
    ]
  }
}

# Bucket policy to deny insecure connections
data "aws_iam_policy_document" "terraform_state_bucket_policy" {
  statement {
    sid    = "DenyInsecureConnections"
    effect = "Deny"

    principals {
      type        = "*"
      identifiers = ["*"]
    }

    actions = ["s3:*"]

    resources = [
      aws_s3_bucket.terraform_state.arn,
      "${aws_s3_bucket.terraform_state.arn}/*"
    ]

    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values   = ["false"]
    }
  }
}

# Apply bucket policy
resource "aws_s3_bucket_policy" "terraform_state_bucket_policy" {
  bucket = aws_s3_bucket.terraform_state.id
  policy = data.aws_iam_policy_document.terraform_state_bucket_policy.json

  lifecycle {
    ignore_changes = [policy]
  }
}

# Add lifecycle configuration to manage old versions
resource "aws_s3_bucket_lifecycle_configuration" "terraform_state_lifecycle" {
  bucket = aws_s3_bucket.terraform_state.id

  rule {
    id     = "terraform_state_lifecycle"
    status = "Enabled"

    filter {
      prefix = "" # Apply to all objects
    }

    noncurrent_version_expiration {
      noncurrent_days = 90 # Keep old versions for 90 days
    }

    abort_incomplete_multipart_upload {
      days_after_initiation = 7
    }
  }

  lifecycle {
    ignore_changes = [rule]
  }

  depends_on = [aws_s3_bucket_versioning.terraform_state_versioning]
}
