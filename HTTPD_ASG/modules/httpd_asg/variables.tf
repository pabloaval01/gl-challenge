variable "subnet_ids" {
  type = list(string)
}

variable "ami_id" {
  type = string
}

variable "instance_type" {
  type    = string
  default = "t2.micro"
}

variable "asg_min_size" {
  type    = number
  default = 2
}

variable "asg_max_size" {
  type    = number
  default = 6
}

variable "bucket_name" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "key_name" {
  type = string
}

variable "tags" {
  type    = map(string)
  default = {}
}
variable "user_data" {
  type = string
}

variable "ec2_asg_demo_pv_key_pair_name" {
  type    = string
  default = "ec2-asg-redhat-test-keypair"
}

variable "instance_name_tag" {
  type = string
}

variable "cidr_for_remote_access" {
  description = "Allow access range per port 22"
  type        = string
}

variable "target_group_arn" {
  type = string
}

variable "alb_security_group_id" {
  type = string
}

variable "iam_instance_profile_name" {
  type = string
}
