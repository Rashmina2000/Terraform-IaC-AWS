# Create VPC
resource "aws_vpc" "main_vpc" {
  cidr_block           = "11.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "terraform-deploy-vpc"
  }
}

# Create a public subnet in us-east-1a
resource "aws_subnet" "public_1" {
  vpc_id                  = aws_vpc.main_vpc.id
  cidr_block              = "11.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "us-east-1a"
  tags = {
    Name = "public-subnet-1"
  }
}

# Create a second public subnet in us-east-1b

resource "aws_subnet" "public_2" {
  vpc_id                  = aws_vpc.main_vpc.id
  cidr_block              = "11.0.2.0/24" # Ensure the CIDR block does not overlap with the first subnet
  map_public_ip_on_launch = true
  availability_zone       = "us-east-1b" # Different AZ
  tags = {
    Name = "public-subnet-2"
  }
}

# Create an Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main_vpc.id
  tags = {
    Name = "terraform-igw"
  }
}

# Create a public route table for the public subnet
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "public-route-table"
  }
}

# Associate the public route table with the first public subnet

resource "aws_route_table_association" "public_association_1" {
  subnet_id      = aws_subnet.public_1.id
  route_table_id = aws_route_table.public.id
}

# Associate the public route table with the second public subnet

resource "aws_route_table_association" "public_association_2" {
  subnet_id      = aws_subnet.public_2.id
  route_table_id = aws_route_table.public.id
}

# Security group for EC2 instances

resource "aws_security_group" "instances" {
  name   = "${var.app_name}-instance-security-group"
  vpc_id = aws_vpc.main_vpc.id
}

resource "aws_security_group_rule" "allow_http_inbound" {
  type              = "ingress"
  security_group_id = aws_security_group.instances.id

  from_port   = 80
  to_port     = 80
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
}

# Target Group for EC2 Instances

resource "aws_lb_target_group" "instances" {
  name     = "${var.app_name}-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main_vpc.id

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

# Register EC2 Instances to the Target Group

resource "aws_lb_target_group_attachment" "instance_1" {
  target_group_arn = aws_lb_target_group.instances.arn
  target_id        = aws_instance.instance_1.id
  port             = 80
}

resource "aws_lb_target_group_attachment" "instance_2" {
  target_group_arn = aws_lb_target_group.instances.arn
  target_id        = aws_instance.instance_2.id
  port             = 80
}

resource "aws_lb_listener_rule" "instances" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 100

  condition {
    path_pattern {
      values = ["*"]
    }
  }

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.instances.arn
  }
}

# Security Group for Load Balancer

resource "aws_security_group" "alb" {
  name   = "${var.app_name}-alb-security-group"
  vpc_id = aws_vpc.main_vpc.id
}

resource "aws_security_group_rule" "allow_alb_http_inbound" {
  type              = "ingress"
  security_group_id = aws_security_group.alb.id

  from_port   = 80 #############
  to_port     = 80 #############
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "allow_alb_all_outbound" {
  type              = "egress"
  security_group_id = aws_security_group.alb.id

  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]
}

# Elastic Load Balancer

resource "aws_lb" "load_balancer" {
  name               = "${var.app_name}-lb"
  load_balancer_type = "application"
  subnets            = [aws_subnet.public_1.id, aws_subnet.public_2.id]
  security_groups    = [aws_security_group.alb.id]
}

# Listener for the Load Balancer

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.load_balancer.arn
  port              = 80 ##############
  protocol          = "HTTP"

  # By default, return a simple 404 page
  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "404: page not found"
      status_code  = 404
    }
  }
}