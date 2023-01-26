variable "region" {
  default = "ap-south-1"
}

variable "env_name" {
  default = "dev"
}

variable "vpc_name" {
  default = "vpc"
}

variable "vpc_cidr" {
  default = "10.0.0.0/16"
}

variable "private_subnets" {
  default = {
    "private_subnet_1" = 1
    "private_subnet_2" = 2
    "private_subnet_3" = 3
  }
}

variable "public_subnets" {
  default = {
    "public_subnet_1" = 1
    "public_subnet_2" = 2
    "public_subnet_3" = 3
  }
}

variable "sub_az" {
  description = "AZ for Variables Subnet"
  default     = "ap-south-1a"
}

variable "sub_auto_ip" {
  description = "Set Automatic IP assignment for Variablrd Subnet"
  default     = true
}

variable "ingress_ipv4" {
  default = "0.0.0.0/0"
}

variable "ingress_ipv6" {
  default = "::/0"
}