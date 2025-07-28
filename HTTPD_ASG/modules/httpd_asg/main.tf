data "template_file" "user_data" {
  template = var.user_data
}

resource "aws_iam_instance_profile" "instance_profile" {
  name = "httpd-asg-instance-profile"
  role = var.iam_instance_role_name
}

# data "template_file" "user_data" {
#   template = var.user_data
# }

############################
### TLS Key + AWS KeyPair ###
############################

resource "tls_private_key" "ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 4096

}

resource "aws_key_pair" "ec2_redhat_key" {
  key_name   = var.ec2_asg_demo_pv_key_pair_name
  public_key = tls_private_key.ssh_key.public_key_openssh
  tags = var.tags

  lifecycle {
    create_before_destroy = true
    ignore_changes        = [public_key] 
  }

}

resource "local_file" "private_key_pem" {
  content         = tls_private_key.ssh_key.private_key_pem
  filename        = "${path.module}/${var.ec2_asg_demo_pv_key_pair_name}.pem"
  file_permission = "0400"

  lifecycle {
    prevent_destroy = true       
    ignore_changes  = [filename] 
  }
}

resource "aws_security_group" "httpd_sg" {
  name        = "${var.instance_name_tag}-sg"
  description = "SG para instancias del ASG"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.cidr_for_remote_access]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port                = 443
    to_port                  = 443
    protocol                 = "tcp"
    security_groups          = [var.alb_security_group_id]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = var.tags
}


resource "aws_launch_template" "httpd_template" {
  name_prefix   = "httpd-launch-template-"
  image_id      = var.ami_id
  instance_type = var.instance_type
  vpc_security_group_ids = [aws_security_group.httpd_sg.id]
  key_name      = var.key_name

  user_data = base64encode(data.template_file.user_data.rendered)

  block_device_mappings {
    device_name = "/dev/xvda"

    ebs {
      volume_size = 20
      volume_type = "gp2"
    }
  }
  
  tag_specifications {
    resource_type = "instance"

    tags = merge(var.tags, {
      Name = var.instance_name_tag  
    })
  }

  tags = var.tags
}

resource "aws_autoscaling_group" "httpd_asg" {
  name                      = "httpd-asg"
  min_size                  = var.asg_min_size
  max_size                  = var.asg_max_size
  desired_capacity          = var.asg_min_size
  vpc_zone_identifier       = var.subnet_ids
  target_group_arns = [var.target_group_arn]

  launch_template {
    id      = aws_launch_template.httpd_template.id
    version = "$Latest"
  }

  lifecycle {
    create_before_destroy = true
  }

  dynamic "tag" {
    for_each = var.tags
    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
}
}