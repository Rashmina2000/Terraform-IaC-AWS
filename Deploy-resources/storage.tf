resource "aws_s3_bucket" "storage-bucket" {
  bucket        = "terraform-storage-bucket2000"
  force_destroy = true
}