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

# Crear carpeta "archive/"

resource "aws_s3_object" "memes_folder" {
  bucket  = aws_s3_bucket.images.id
  key     = "archive/Memes/"
  content = ""
}

# Lifecycle para carpeta "Memes/"
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



# resource "aws_iam_role" "asg_read_images" {
#   name = "asg-s3-read-role-${random_integer.bucket_suffix.result}"

#   assume_role_policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [{
#       Effect    = "Allow"
#       Principal = { Service = "ec2.amazonaws.com" }
#       Action    = "sts:AssumeRole"
#     }]
#   })
# }

# resource "aws_iam_policy" "asg_read_images" {
#   name = "asg-s3-read-policy-${random_integer.bucket_suffix.result}"
#   policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [{
#       Effect = "Allow"
#       Action = ["s3:ListBucket", "s3:GetObject"]
#       Resource = [
#         aws_s3_bucket.images.arn,
#         "${aws_s3_bucket.images.arn}/*"
#       ]
#     }]
#   })
# }

# resource "aws_iam_role_policy_attachment" "asg_read_images_attach" {
#   role       = aws_iam_role.asg_read_images.name
#   policy_arn = aws_iam_policy.asg_read_images.arn
# }
