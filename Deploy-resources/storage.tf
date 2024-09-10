resource "aws_s3_bucket" "storage-bucket" {
  bucket        = "terraform-storage-bucket2000" # Replace with your bucket name
  force_destroy = true
}