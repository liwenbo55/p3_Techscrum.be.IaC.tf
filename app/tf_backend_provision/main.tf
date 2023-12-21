provider "aws" {
  region = "ap-southeast-2"
}

# Three s3 buckets for ".tfstate" file of pro & uat & dev environments
resource "aws_s3_bucket" "backend_statefile" {
  bucket        = "p3.techscrum.backend-terraform.statefile"
  force_destroy = true
}

# Three dynamodb tables for prod & uat & dev environments
resource "aws_dynamodb_table" "dynamodb-terraform-state-lock-prod" {
  name         = "techscrum-backend-terraform.state-lock-prod"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"
  attribute {
    name = "LockID"
    type = "S"
  }
}

resource "aws_dynamodb_table" "dynamodb-terraform-state-lock-uat" {
  name         = "techscrum-backend-terraform.state-lock-uat"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"
  attribute {
    name = "LockID"
    type = "S"
  }
}

resource "aws_dynamodb_table" "dynamodb-terraform-state-lock-dev" {
  name         = "techscrum-backend-terraform.state-lock-dev"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"
  attribute {
    name = "LockID"
    type = "S"
  }
}

# resource "aws_dynamodb_table" "dynamodb-terraform-state-lock-l" {
#   name         = "crankbit-backend-terraform.state-lock-l"
#   billing_mode = "PAY_PER_REQUEST"
#   hash_key     = "LockID"
#   attribute {
#     name = "LockID"
#     type = "S"
#   }
# }