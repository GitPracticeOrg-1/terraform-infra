# this is terraform statefile bucket with best practices - versioning, encryption, and public access block
resource "aws_s3_bucket" "backend_state" {
  bucket = "kakarot-terraform-backend"
  tags = {
    Name        = "kakarot-terraform-backend"
    Environment = "Dev"
  }
}

# versioning enabled for state file integrity and recovery
resource "aws_s3_bucket_versioning" "backend_state" {
  bucket = aws_s3_bucket.backend_state.id
  versioning_configuration {
    status = "Enabled"
  }
}

# security - block public access
resource "aws_s3_bucket_public_access_block" "backend_state" {
  bucket                  = aws_s3_bucket.backend_state.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# encryption at rest
resource "aws_s3_bucket_server_side_encryption_configuration" "backend_state" {
  bucket = aws_s3_bucket.backend_state.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_policy" "backend_state" {
  bucket = aws_s3_bucket.backend_state.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Deny"
        Principal = "*"
        Action    = "s3:*"
        Resource = [
          "${aws_s3_bucket.backend_state.arn}/*",
          aws_s3_bucket.backend_state.arn
        ]
        Condition = {
          Bool = {
            "aws:SecureTransport" = "false"
          }
        }
      }
    ]
  })
}

resource "aws_instance" "kubernetes" {
  ami           = "ami-07a00cf47dbbc844c"
  instance_type = "t3.small"
  key_name      = "aws"

  tags = {
    Name = "Kubernetes"
  }
}

# terraform {
#   backend "s3" {
#     bucket       = "kakarot-terraform-backend-aws-devops"
#     key          = "terraform.tfstate"
#     region       = "ap-south-1"
#     encrypt      = true
#     use_lockfile = true
#   }
# }
