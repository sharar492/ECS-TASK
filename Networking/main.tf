terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}
# Configure the AWS Provider
provider "aws" {
  region = "us-east-1"
}

# VPC Configuration
resource "aws_vpc" "my_vpc" {
  cidr_block           = var.cidr_block
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "my-vpc"
  }
}

# Subnet 1 configuration Public
resource "aws_subnet" "subnet-1" {
  vpc_id                  = aws_vpc.my_vpc.id
  cidr_block              = var.cidr_for_subnet1
  map_public_ip_on_launch = true
  availability_zone       = "us-east-1a"

  tags = {
    Name = "subnet-1"
  }
}

# Subnet 2 configuration Private
resource "aws_subnet" "subnet-2" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = var.cidr_for_subnet2
  availability_zone = "us-east-1b"

  tags = {
    Name = "subnet-2"
  }
}

# Internet Gateway for public subnet
resource "aws_internet_gateway" "igw1" {
  vpc_id = aws_vpc.my_vpc.id

  tags = {
    Name = "igw-1"
  }

}

# Route table for public subnet
resource "aws_route_table" "rt-id" {
  vpc_id = aws_vpc.my_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw1.id
  }
}

# Route table association for public subnet
resource "aws_route_table_association" "public_subnet_association" {
  subnet_id      = aws_subnet.subnet-1.id
  route_table_id = aws_route_table.rt-id.id
}

# Elastic IP for NAT Gateway
resource "aws_eip" "nat_eip" {
  domain = "vpc"
}

# NAT Gateway for private subnet
resource "aws_nat_gateway" "ngw" {
  subnet_id = aws_subnet.subnet-2.id
  allocation_id = aws_eip.nat_eip.id

  tags = {
    Name = "nat-gateway"
  }
}

# Route table for the private subnet
resource "aws_route_table" "prt-id" {
  vpc_id = aws_vpc.my_vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.ngw.id
  }
}

# Route table association for Private Subnet
resource "aws_route_table_association" "private_subnet_association" {
  subnet_id      = aws_subnet.subnet-2.id
  route_table_id = aws_route_table.prt-id.id
}

# Security group for private Subnet

resource "aws_security_group" "sg1" {
  name        = "private-sg"
  description = "security group for instances in the private subnet"
  vpc_id      = aws_vpc.my_vpc.id

  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP"
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

