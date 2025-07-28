module "s3_images_bucket" {
  source = "./modules/s3_images"

  tags = var.tags
}


# module "httpd_asg" {
#   source                 = "./modules/httpd_asg"
#   subnet_ids             = [data.aws_subnet.sub3.id, data.aws_subnet.sub4.id]
#   ami_id                 = data.aws_ami.redhat.id
#   vpc_id                 = data.aws_vpc.vpc_nfw.id
#   cidr_for_remote_access = "10.1.1.0/24"
#   key_name               = "ec2-asg-redhat-test-keypair"
#   bucket_name            = module.s3_images_bucket.bucket_name
#   iam_instance_role_name = module.s3_images_bucket.iam_role_name
#   user_data              = file("${path.module}/user-data/install_httpd.sh")
#   target_group_arn       = module.alb_http_to_asg.target_group_arn
#   alb_security_group_id  = module.alb_http_to_asg.alb_security_group_id
#   tags                   = var.tags
#   instance_name_tag      = "httpd-asg-instance"

# }
module "httpd_asg" {
  source                 = "./modules/httpd_asg"
  subnet_ids             = [data.aws_subnet.sub3.id, data.aws_subnet.sub4.id]
  ami_id                 = data.aws_ami.redhat.id
  vpc_id                 = data.aws_vpc.vpc_nfw.id
  cidr_for_remote_access = "10.1.1.0/24"
  key_name               = "ec2-asg-redhat-test-keypair"
  bucket_name            = module.s3_images_bucket.bucket_name
  iam_instance_role_name = module.s3_images_bucket.iam_role_name
  user_data              = file("${path.module}/user-data/install_httpd.sh")
  target_group_arn       = module.alb_http_to_asg.target_group_arn
  alb_security_group_id  = module.alb_http_to_asg.alb_security_group_id
  tags                   = var.tags
  instance_name_tag      = "httpd-asg-instance"
}


module "alb_http_to_asg" {
  asg_name    = module.alb_http_to_asg.alb_security_group_id
  source      = "./modules/alb_http_to_asg"
  target_port = 443
  tags        = var.tags
}