terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Using variable for region
provider "aws" {
  region = var.aws_region
}

# fetches the current AWS region
data "aws_region" "current" {}

# fetches available AZs in the region
data "aws_availability_zones" "all" {}

# fetches the latest Ubuntu 22.04 AMI
data "aws_ami" "ubuntu_22_04" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  owners = ["099720109477"]
}

# Security group for EC2 instances in the ASG
resource "aws_security_group" "instance_sg" {
  name        = "terraform-instance-sg-day4"
  description = "Allow HTTP traffic to instances"

  ingress {
    from_port   = var.server_port
    to_port     = var.server_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Security group for the ALB
resource "aws_security_group" "alb_sg" {
  name        = "terraform-alb-sg-day4"
  description = "Allow HTTP traffic to ALB"

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
}

# Launch template defining the instance spec
resource "aws_launch_template" "web_server" {
  name_prefix   = "terraform-web-server-day4"
  image_id      = data.aws_ami.ubuntu_22_04.id
  instance_type = var.instance_type

  vpc_security_group_ids = [aws_security_group.instance_sg.id]

  user_data = base64encode(<<-EOF
              #!/bin/bash
              apt-get update -y
              apt-get install -y apache2
              systemctl start apache2
              systemctl enable apache2
              echo "<h1>Hello from Terraform! Deployed by Grace Zawadi</h1>" > /var/www/html/index.html
              EOF
  )

  tags = {
    Name = var.server_name
  }
}

# Auto Scaling Group - min 2, max 5 instances
resource "aws_autoscaling_group" "web_asg" {
  desired_capacity    = 2
  min_size            = 2
  max_size            = 5
  vpc_zone_identifier = data.aws_subnets.default.ids

  launch_template {
    id      = aws_launch_template.web_server.id
    version = "$Latest"
  }

  target_group_arns = [aws_lb_target_group.web_tg.arn]
  health_check_type = "ELB"

  tag {
    key                 = "Name"
    value               = "terraform-asg-day4"
    propagate_at_launch = true
  }
}

# Application Load Balancer
resource "aws_lb" "web_alb" {
  name               = "terraform-alb-day4"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = data.aws_subnets.default.ids
}

# Target Group
resource "aws_lb_target_group" "web_tg" {
  name     = "terraform-tg-day4"
  port     = var.server_port
  protocol = "HTTP"
  vpc_id   = data.aws_vpc.default.id

  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 15
    timeout             = 3
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

# Listener connecting ALB to Target Group
resource "aws_lb_listener" "web_listener" {
  load_balancer_arn = aws_lb.web_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web_tg.arn
  }
}

# Fetch the default VPC
data "aws_vpc" "default" {
  default = true
}

# Fetch the default subnets
data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

# Output the ALB DNS name
output "alb_dns_name" {
  value       = aws_lb.web_alb.dns_name
  description = "The DNS name of the load balancer"
}