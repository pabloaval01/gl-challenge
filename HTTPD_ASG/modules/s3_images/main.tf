resource "random_integer" "bucket_suffix" {
  min = 10000
  max = 99999
}

resource "aws_s3_bucket" "images" {
  bucket = "images-${random_integer.bucket_suffix.result}"
  tags   = var.tags
}

resource "aws_s3_bucket_versioning" "images_versioning" {
  bucket = aws_s3_bucket.images.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_object" "memes_folder" {
  bucket  = aws_s3_bucket.images.id
  key     = "archive/Memes/"
  content = ""
}

resource "aws_s3_bucket_lifecycle_configuration" "images_lifecycle" {
  bucket = aws_s3_bucket.images.id

  rule {
    id     = "memes-to-glacier"
    status = "Enabled"

    filter {
      prefix = "archive/Memes/"
    }

    transition {
      days          = 90
      storage_class = "GLACIER"
    }
  }
}
