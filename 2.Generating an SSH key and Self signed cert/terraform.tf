terraform {
  required_providers {
    tls = {
      source  = "hashicorp/tls"
      version = "4.0.4"
    }

    aws = {
      source  = "hashicorp/aws"
      version = "4.51.0"
    }
  }
}