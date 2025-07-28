data "aws_vpc" "vpc_nfw" {
  filter {
    name   = "tag:Name"
    values = ["vpc-nfw"]
  }
}

data "aws_subnet" "sub1" {
  filter {
    name   = "tag:Name"
    values = ["vpc-nfw-public-us-east-1a"]
  }
}

data "aws_subnet" "sub2" {
  filter {
    name   = "tag:Name"
    values = ["vpc-nfw-public-us-east-1b"]
  }
}

locals {
  public_subnet_ids = [
    data.aws_subnet.sub1.id,
    data.aws_subnet.sub2.id
  ]
}


resource "aws_security_group" "alb_sg" {
  name        = "alb-http-sg"
  vpc_id      = data.aws_vpc.vpc_nfw.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = var.tags
}


resource "aws_lb" "http_alb" {
  name               = "alb-http"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = local.public_subnet_ids

  tags = var.tags
}

###################################
### Target Group → ASG (port 443) ###
###################################

resource "aws_lb_target_group" "asg_tg" {
  name     = "alb-asg-tg"
  port     = var.target_port
  protocol = "HTTPS"
  vpc_id   = data.aws_vpc.vpc_nfw.id
  target_type = "instance"  

  health_check {
    path                = "/"
    protocol            = "HTTPS"
    matcher             = "200-399"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
    port                = 443
  }

  tags = var.tags
}

##########################
### Listener → Target Group ###
##########################


resource "aws_lb_listener" "http_listener" {
  load_balancer_arn = aws_lb.http_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.asg_tg.arn
  }
}

