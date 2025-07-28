#####################
### DATA SOURCES  ###
#####################

data "aws_vpc" "vpc_nfw" {
  filter {
    name   = "tag:Name"
    values = ["vpc-nfw"]
  }
}

data "aws_subnet" "sub2" {
  filter {
    name   = "tag:Name"
    values = ["vpc-nfw-public-us-east-1b"]
  }

  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.vpc_nfw.id]
  }
}

data "aws_kms_key" "backend_key" {
  key_id = "alias/globallogic-demo-terraform-backend-key"
}

#################
### KEY Pair  ###
#################

# Generate TLS keys
resource "tls_private_key" "ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Key Pair
resource "aws_key_pair" "ec2_redhat_key" {
  key_name   = var.ec2_demo_pv_key_pair_name
  public_key = tls_private_key.ssh_key.public_key_openssh

  lifecycle {
    create_before_destroy = true
    ignore_changes        = [public_key]
  }
}

# Save key locally
resource "local_file" "private_key_pem" {
  content         = tls_private_key.ssh_key.private_key_pem
  filename        = "${path.module}/${var.ec2_demo_pv_key_pair_name}.pem"
  file_permission = "0400"
  lifecycle {
    prevent_destroy = true
    ignore_changes  = [filename]
  }

}

###########
### EC2 ###
###########

module "ec2_test" {
  source            = "github.com/Coalfire-CF/terraform-aws-ec2"
  name              = var.instance_name
  ami               = data.aws_ami.redhat.id
  ec2_instance_type = var.instance_type
  instance_count    = var.instance_count
  ebs_optimized     = false # --> The instance type (t2.micro) has an EBS Optimized value of (unsupported),
  vpc_id            = data.aws_vpc.vpc_nfw.id
  subnet_ids        = [data.aws_subnet.sub2.id] # --> Subnet2
  ec2_key_pair    = var.ec2_demo_pv_key_pair_name
  ebs_kms_key_arn = data.aws_kms_key.backend_key.arn
  root_volume_size = var.instance_volume_size

  # Security Group Rules
  ingress_rules = {
    "ssh" = {
      ip_protocol = "tcp"
      from_port   = 22
      to_port     = 22
      cidr_ipv4   = var.cidr_for_remote_access
      description = "SSH access"
    }
  }

  egress_rules = {
    "allow_all_egress" = {
      ip_protocol = "-1"
      from_port   = 0
      to_port     = 0
      cidr_ipv4   = "0.0.0.0/0"
      description = "Allow all egress"
    }
  }

  # Tagging
  global_tags = var.tags
}