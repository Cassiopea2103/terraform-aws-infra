# provider setup :
provider "aws" {
  region = "us-east-1"
}

# VPC and subnet 
resource "aws_vpc" "main_vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "LAB-VPC-GITHUB_ACTIONS"
  }
}

resource "aws_subnet" "main_subnet" {
  vpc_id            = aws_vpc.main_vpc.id
  cidr_block        = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone = "us-east-1a" 
  tags = {
    Name = "LAB-SUBNET-GITHUB_ACTIONS"
  }
}



# EC2 instance 
resource "aws_instance" "ubuntu_nginx" {
  ami           = "ami-005fc0f236362e99f"  #ubuntu 22.04 LTS
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.main_subnet.id

  tags = {
    Name = "Ubuntu-NGINX-EC2-GITHUB_ACTIONS"
  }

  # pre-install nginx on the EC2 instance :
  user_data = <<-EOF
    #!/bin/bash
    apt update -y
    apt install nginx -y
    systemctl start nginx
    systemctl enable nginx
  EOF
}

resource "aws_security_group" "http_sg" {
  vpc_id = aws_vpc.main_vpc.id

  # Allow HTTP traffic from within the VPC
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]  # Allow traffic from anywhere in the VPC
  }

  # Allow HTTP traffic from within the specific subnet
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["10.0.1.0/24"]  # Allow traffic from the specific subnet
  }

  # Allow HTTP traffic from anywhere (for public access)
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Allow traffic from anywhere (public access)
  }

  # Egress rule (allow all outbound traffic)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]  # Allow outbound traffic
  }

  tags = {
    Name = "Allow-HTTP"
  }
}