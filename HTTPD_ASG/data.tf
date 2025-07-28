# VPC
data "aws_vpc" "vpc_nfw" {
  filter {
    name   = "tag:Name"
    values = ["vpc-nfw"]
  }
}

data "aws_subnet" "sub3" {
  filter {
    name   = "tag:Name"
    values = ["vpc-nfw-private-a-us-east-1a"]
  }

  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.vpc_nfw.id]
  }
}

data "aws_subnet" "sub4" {
  filter {
    name   = "tag:Name"
    values = ["vpc-nfw-private-b-us-east-1b"]
  }

  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.vpc_nfw.id]
  }
}

data "aws_ami" "redhat" {
  most_recent = true
  owners      = ["309956199498"]

  filter {
    name   = "name"
    values = ["RHEL-9.*x86_64-*"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
}
