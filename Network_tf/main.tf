# ---------------------------
# Terraform AWS Network Setup for Cyber Deception Game (Full Version)
# ---------------------------

provider "aws" {
  region = "us-east-2"
}

# ---------------------------
# 1. VPC & Subnets
# ---------------------------
resource "aws_vpc" "main_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support  = true
  enable_dns_hostnames = true
  tags = { Name = "deception-vpc" }
}

locals {
  az = "us-east-2a"
}

resource "aws_subnet" "public_web" {
  vpc_id                  = aws_vpc.main_vpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = local.az
  tags = { Name = "public-web-subnet" }
}

resource "aws_subnet" "private_a" {
  vpc_id            = aws_vpc.main_vpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = local.az
  tags = { Name = "private-a-subnet" }
}

resource "aws_subnet" "private_b" {
  vpc_id            = aws_vpc.main_vpc.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = local.az
  tags = { Name = "private-b-subnet" }
}

resource "aws_subnet" "controller" {
  vpc_id            = aws_vpc.main_vpc.id
  cidr_block        = "10.0.4.0/24"
  availability_zone = local.az
  tags = { Name = "controller-subnet" }
}

# ---------------------------
# 2. Gateways and Routing
# ---------------------------
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main_vpc.id
  tags = { Name = "main-igw" }
}

resource "aws_eip" "nat_eip" {
  vpc = true
}

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.public_web.id
  tags = { Name = "main-nat" }
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = { Name = "public-rt" }
}

resource "aws_route_table_association" "public_assoc" {
  subnet_id      = aws_subnet.public_web.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.main_vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }
  tags = { Name = "private-rt" }
}

resource "aws_route_table_association" "privatea_assoc" {
  subnet_id      = aws_subnet.private_a.id
  route_table_id = aws_route_table.private_rt.id
}

resource "aws_route_table_association" "privateb_assoc" {
  subnet_id      = aws_subnet.private_b.id
  route_table_id = aws_route_table.private_rt.id
}

resource "aws_route_table_association" "controller_assoc" {
  subnet_id      = aws_subnet.controller.id
  route_table_id = aws_route_table.public_rt.id
}

# ---------------------------
# 3. Security Group
# ---------------------------
resource "aws_security_group" "instance_sg" {
  name        = "deception-sg"
  description = "Allow internal traffic and SSH"
  vpc_id      = aws_vpc.main_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 17737
    to_port     = 17737
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# ---------------------------
# 4. EC2 Instances
# ---------------------------
variable "ami_id" {
  default = "ami-0c262369dcdfc38a8" # Ubuntu 24.04 LTS
}

variable "instance_type" {
  default = "t3.medium"
}

locals {
  instance_defs = [
    { name = "PublicWeb1", subnet = aws_subnet.public_web.id },
    { name = "PublicWeb2", subnet = aws_subnet.public_web.id },
    { name = "NTP",         subnet = aws_subnet.private_a.id },
    { name = "DB",          subnet = aws_subnet.private_a.id },
    { name = "InternalWeb", subnet = aws_subnet.private_b.id },
    { name = "PC1",         subnet = aws_subnet.private_b.id },
    { name = "PC2",         subnet = aws_subnet.private_b.id },
    { name = "PC3",         subnet = aws_subnet.private_b.id },
    { name = "Controller",  subnet = aws_subnet.controller.id },
  ]
}

resource "aws_instance" "nodes" {
  for_each               = { for inst in local.instance_defs : inst.name => inst }
  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = each.value.subnet
  key_name               = "RL4Deception"
  associate_public_ip_address = contains(["Controller", "PublicWeb1", "PublicWeb2"], each.key)
  vpc_security_group_ids = [aws_security_group.instance_sg.id]
  tags = {
    Name = each.key
  }
}

# Elastic IP for Controller
resource "aws_eip" "controller_eip" {
  instance = aws_instance.nodes["Controller"].id
  vpc      = true
  depends_on = [aws_internet_gateway.igw] # Ensures IGW is created first
}


# ---------------------------
# 5. Outputs
# ---------------------------
output "controller_ip" {
  value = aws_instance.nodes["Controller"].public_ip
}

output "public_web1_ip" {
  value = aws_instance.nodes["PublicWeb1"].public_ip
}

output "public_web2_ip" {
  value = aws_instance.nodes["PublicWeb2"].public_ip
} 

output "all_private_ips" {
  value = {
    for name, inst in aws_instance.nodes :
    name => inst.private_ip
  }
}