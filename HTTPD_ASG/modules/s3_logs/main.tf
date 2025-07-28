resource "random_integer" "bucket_suffix" {
  min = 10000
  max = 99999
}

resource "aws_s3_bucket" "logs" {
  bucket = "logs-${random_integer.bucket_suffix.result}"
  tags   = var.tags
}

resource "aws_s3_bucket_versioning" "logs_versioning" {
  bucket = aws_s3_bucket.logs.id
  versioning_configuration {
    status = "Enabled"
  }
}


resource "aws_s3_object" "active_folder" {
  bucket  = aws_s3_bucket.logs.id
  key     = "active/"
  content = ""
}
resource "aws_s3_object" "inactive_folder" {
  bucket  = aws_s3_bucket.logs.id
  key     = "inactive/"
  content = ""
}


resource "aws_s3_bucket_lifecycle_configuration" "logs_lifecycle" {
  bucket = aws_s3_bucket.logs.id

  rule {
    id     = "active-to-glacier"
    status = "Enabled"

    filter {
      prefix = "active/"
    }

    transition {
      days          = 90
      storage_class = "GLACIER"
    }
  }
  rule {
    id     = "inactive-delete"
    status = "Enabled"

    filter {
      prefix = "inactive/"
    }

    expiration {
      days = 90
    }
  }

}


# resource "aws_iam_role" "ec2_write_logs" {
#   name = "asg-s3-write-role-${random_integer.bucket_suffix.result}"

#   assume_role_policy = jsonencode({
#     Version = "2012-10-17",
#     Statement = [{
#       Effect    = "Allow",
#       Principal = {
#         Service = "ec2.amazonaws.com"
#       },
#       Action    = "sts:AssumeRole"
#     }]
#   })
# }

# resource "aws_iam_policy" "ec2_write_logs" {
#   name = "asg-s3-write-policy-${random_integer.bucket_suffix.result}"
#   policy = jsonencode({
#     Version = "2012-10-17",
#     Statement = [{
#       Effect = "Allow",
#       Action = [
#         "s3:PutObject",
#         "s3:PutObjectAcl"
#       ],
#       Resource = "${aws_s3_bucket.logs.arn}/*"
#     }]
#   })
# }

# resource "aws_iam_role_policy_attachment" "ec2_write_logs_attach" {
#   role       = aws_iam_role.ec2_write_logs.name
#   policy_arn = aws_iam_policy.ec2_write_logs.arn
# }
