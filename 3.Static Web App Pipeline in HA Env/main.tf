/*
ToDo
• Task 1: Upload your SSH keypair to AWS and associate to your instance.
• Task 2: Create a Security Group that allows SSH to your instance.
• Task 3: Create a connection block using your SSH keypair.
• Task 4: Use the local-exec provisioner to change permissions on your local SSH Key
• Task 5: Create a remote-exec provisioner block to pull down and install web application.
• Task 6: Apply your configuration and watch for the remote connection.
*/

provider "aws" {
  region = var.region
}

#Place the github repo link
locals {
  git_repo_link = ""
}

#Get all AZs
data "aws_availability_zones" "available" {}
data "aws_region" "current" {}

#AMI data block
data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"]
}

#VPC Definition
resource "aws_vpc" "vpc" {
  cidr_block = var.vpc_cidr

  tags = {
    "Name"      = var.vpc_name
    Environment = var.env_name
    Terraform   = true
  }
}

#Subnets Definition
resource "aws_subnet" "private_subnets" {
  for_each          = var.private_subnets
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = cidrsubnet(var.vpc_cidr, 8, each.value)
  availability_zone = tolist(data.aws_availability_zones.available.names)[each.value - 1]

  tags = {
    "Name"    = each.key
    Terraform = true
  }
}

resource "aws_subnet" "public_subnets" {
  for_each                = var.public_subnets
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = cidrsubnet(var.vpc_cidr, 8, each.value + 100)
  availability_zone       = tolist(data.aws_availability_zones.available.names)[each.value - 1]
  map_public_ip_on_launch = true

  tags = {
    "Name"    = each.key
    Terraform = true
  }
}

#Route Tables
resource "aws_route_table" "private_rtb" {
  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gw.id
  }
  tags = {
    "Name"    = "private_rtb"
    Terraform = true
  }
}

resource "aws_route_table" "public_rtb" {
  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet_gw.id
  }
  tags = {
    "Name"    = "public_rtb"
    Terraform = true
  }
}

#RTB Associations
resource "aws_route_table_association" "private_rtb_association" {
  depends_on = [
    aws_subnet.private_subnets
  ]
  route_table_id = aws_route_table.private_rtb.id
  for_each       = aws_subnet.private_subnets
  subnet_id      = each.value.id
}

resource "aws_route_table_association" "public_rtb_association" {
  depends_on = [
    aws_subnet.public_subnets
  ]
  route_table_id = aws_route_table.public_rtb.id
  for_each       = aws_subnet.public_subnets
  subnet_id      = each.value.id
}

# IGW, NatGW and EIP for same
resource "aws_internet_gateway" "internet_gw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name      = "internet_gw"
    Terraform = true
  }
}

resource "aws_eip" "eip" {
  vpc = true
  depends_on = [
    aws_internet_gateway.internet_gw
  ]
  tags = {
    "Name"    = "ngw_eip"
    Terraform = true
  }
}

resource "aws_nat_gateway" "nat_gw" {
  allocation_id = aws_eip.eip.id
  depends_on    = [aws_subnet.public_subnets]
  subnet_id     = aws_subnet.public_subnets["public_subnet_1"].id

  tags = {
    Name      = "Nat_gw"
    Terraform = true
  }
}

#Creating a SSH Key
resource "tls_private_key" "private_key" {
  algorithm = "RSA"
}

resource "local_file" "private_key_pem" {
  content  = tls_private_key.private_key.private_key_pem
  filename = "pvtKey.pem"
}

#Create Key pair
resource "aws_key_pair" "private_key" {
  key_name   = "AWS_web_server_key"
  public_key = tls_private_key.private_key.public_key_openssh
  tags = {
    "Name"    = "private_key_pair"
    Terraform = true
  }

  lifecycle {
    ignore_changes = [key_name]
  }
}

#Task 2: Security Group 

# A. SSH Ingress
resource "aws_security_group" "sg-ingress-ssh" {
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    description      = "Open to Internet"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = [var.ingress_ipv4]
    ipv6_cidr_blocks = [var.ingress_ipv6]
  }

  egress {
    description      = "Allow all IP and Ports Outbound"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name      = "Public SG"
    Terraform = true
  }
}

# B. Web- traffic
resource "aws_security_group" "vpc-web" {
  name        = "vpc-web-${terraform.workspace}"
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    description      = "Allow Port 80"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = [var.ingress_ipv4]
    ipv6_cidr_blocks = [var.ingress_ipv6]
  }

  ingress {
    description      = "Allow Port 443"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = [var.ingress_ipv4]
    ipv6_cidr_blocks = [var.ingress_ipv6]
  }

  egress {
    description      = "Allow all IP and Ports Outbound"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name      = "sg-web-server"
    Terraform = true
  }
}

# C. ICMP Traffic
resource "aws_security_group" "vpc-ping" {
  name        = "vpc-ping"
  description = "ICMP for ping"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    description      = "Allow ICMP Traffic"
    from_port        = -1
    to_port          = -1
    protocol         = "icmp"
    cidr_blocks      = [var.ingress_ipv4]
    ipv6_cidr_blocks = [var.ingress_ipv6]
  }

  egress {
    description      = "Allow all IP and Ports Outbound"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "vpc-ping"

  }
}

# Task 3: Create a connection to the EC2 using key pair

#Create EC2 Web Server
resource "aws_instance" "web_server" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.public_subnets["public_subnet_1"].id

  security_groups = [
    aws_security_group.sg-ingress-ssh.id,
    aws_security_group.vpc-web.id,
    aws_security_group.vpc-ping.id
  ]

  associate_public_ip_address = true
  key_name                    = aws_key_pair.private_key.key_name

  connection {
    user        = "ubuntu"
    private_key = tls_private_key.private_key.id
    host        = self.public_ip
  }

  tags = {
    "Name"    = "Web Server"
    Terraform = true
  }

  lifecycle {
    ignore_changes = [
      security_groups
    ]
  }

  # Task 4: Change permission for SSH key
  provisioner "local-exec" {
    command = "chmod 600 ${local_file.private_key_pem.filename}"
  }


  # Task 5: Remote Execution for pulling git
  provisioner "remote-exec" {
    inline = [
      "sudo rm -rf /tmp",
      "sudo git clone ${local.git_repo_link}"
    ]
  }
}