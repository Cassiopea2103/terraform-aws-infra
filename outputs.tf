output "vpc_id" {
  value = aws_vpc.main_vpc.id
}

output "subnet_id" {
  value = aws_subnet.main_subnet.id
}

output "instance_public_ip" {
  value = aws_instance.ubuntu_nginx.public_ip
}
