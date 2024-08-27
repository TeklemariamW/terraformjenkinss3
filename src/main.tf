provider "aws" {
  region     = "us-east-1"  # N. Virginia region
  access_key = "your-access-key-id"  # Use environment variables or secrets manager for real deployments
  secret_key = "your-secret-access-key"  # Use environment variables or secrets manager for real deployments
}

resource "aws_s3_bucket" "student_bucket" {
  bucket = "unique-studentterraform-bucket-name"
  acl    = "private"  # Set ACL directly here
  tags = {
    Name        = "studentBucket"
    Environment = "Dev"
  }
}

resource "aws_s3_bucket_object" "bronze_layer" {
  bucket = aws_s3_bucket.student_bucket.bucket
  key    = "bronze/"
  acl    = "private"
}

resource "aws_s3_bucket_object" "silver_layer" {
  bucket = aws_s3_bucket.student_bucket.bucket
  key    = "silver/"
  acl    = "private"
}

resource "aws_s3_bucket_object" "gold_layer" {
  bucket = aws_s3_bucket.student_bucket.bucket
  key    = "gold/"
  acl    = "private"
}

output "bucket_name" {
  value = aws_s3_bucket.student_bucket.bucket
}
