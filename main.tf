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

