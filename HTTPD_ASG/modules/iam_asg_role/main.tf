resource "aws_iam_role" "asg_role" {
  name = "asg-consolidated-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect    = "Allow",
      Principal = { Service = "ec2.amazonaws.com" },
      Action    = "sts:AssumeRole"
    }]
  })

  tags = var.tags
}

resource "aws_iam_policy" "policy_images" {
  name = "asg-s3-read-policy-images"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Action = [
        "s3:GetObject",
        "s3:PutObject",
        "s3:PutObjectAcl"
      ],
      Resource = "${var.images_bucket_arn}/*"
    }]
  })

  tags = var.tags
}

resource "aws_iam_policy" "policy_logs" {
  name = "asg-s3-write-policy-logs"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Action = [
        "s3:PutObject",
        "s3:PutObjectAcl"
      ],
      Resource = "${var.logs_bucket_arn}/*"
    }]
  })

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "attach_images" {
  role       = aws_iam_role.asg_role.name
  policy_arn = aws_iam_policy.policy_images.arn
}

resource "aws_iam_role_policy_attachment" "attach_logs" {
  role       = aws_iam_role.asg_role.name
  policy_arn = aws_iam_policy.policy_logs.arn
}

resource "aws_iam_instance_profile" "asg_instance_profile" {
  name = "asg-instance-profile"
  role = aws_iam_role.asg_role.name

  tags = var.tags
}

output "iam_role_name" {
  value = aws_iam_role.asg_role.name
}

output "instance_profile_name" {
  value = aws_iam_instance_profile.asg_instance_profile.name
}
