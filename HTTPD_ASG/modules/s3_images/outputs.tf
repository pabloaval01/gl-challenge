output "bucket_name" {
  value = aws_s3_bucket.images.bucket
}

output "iam_role_name" {
  value = aws_iam_role.asg_read_images.name
}
