provider "aws" {
  region = "us-east-1"
}
resource "aws_vpc" "kalki-2898" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "kalki"
  }
}
resource "aws_internet_gateway" "gateway-kalki" {
  vpc_id = aws_vpc.kalki-2898.id

  tags = {
    Name = "gate-kalki"
  }
}
resource "aws_route_table" "RT" {
  vpc_id = aws_vpc.kalki-2898.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gateway-kalki.id
  }
  tags = {
    Name = "RT"
  }
}
resource "aws_subnet" "bujji" {
  vpc_id     = aws_vpc.kalki-2898.id
  cidr_block = "10.0.1.0/24"

  tags = {
    Name = "bujji-kalki"
  }
}
resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.bujji.id
  route_table_id = aws_route_table.RT.id
}
resource "aws_security_group" "kalki_sg" {
  name        = "PublicSecurityGroup"
  description = "Allow HTTP and HTTPS from anywhere"
  vpc_id      = aws_vpc.kalki-2898.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
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
resource "aws_instance" "ubuntu" {
  ami                         = "ami-04b70fa74e45c3917"
  instance_type               = "t2.micro"
  key_name                    = "terrraa"
  security_groups             = [aws_security_group.kalki_sg.id]
  subnet_id                   = aws_subnet.bujji.id
  associate_public_ip_address = true
  user_data                   = <<-EOF
                                #!/bin/bash
                                apt update -y
                                apt install -y apache2
                                systemctl start apache2
                                systemctl enable apache2
                                EOF
  tags = {
    Name = "Ubuntu-server"
  }
}
resource "aws_network_interface" "K-2898-bujji" {
  subnet_id       = aws_subnet.bujji.id
  private_ips     = ["10.0.1.24"]
  security_groups = [aws_security_group.kalki_sg.id]

  attachment {
    instance     = aws_instance.ubuntu.id
    device_index = 1
  }
}
resource "aws_eip_association" "eip_assoc" {
  instance_id          = aws_instance.ubuntu-kalki.id
  allocation_id        = aws_eip.example.id
  network_interface_id = aws_network_interface.K-2898-bujji.id
}
resource "aws_instance" "ubuntu-kalki" {
  ami               = "ami-04b70fa74e45c3917"
  availability_zone = "us-east-1a"
  instance_type     = "t2.micro"
  tags = {
    Name = "Hello"
  }
}
resource "aws_eip" "example" {
  domain = "vpc"
}
resource "aws_s3_bucket" "s3_bucket" {
    bucket = "kalki-terra"
    acl = "private"
}
resource "aws_dynamodb_table" "dynamodb-terraform-state-lock" {
  name = "terraform-state-lock-dynamo"
  hash_key = "LockID"
  read_capacity = 20
  write_capacity = 20
  attribute {
    name = "LockID"
    type = "S"
  }
}
terraform {
  backend "s3" {
    bucket = "kalki-terra"
    dynamodb_table = "terraform-state-lock-dynamo"
    key    = "terraform.tfstate"
    region = "us-east-1"
  }
}