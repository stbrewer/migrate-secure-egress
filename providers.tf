terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "5.0.0"
    }
    aviatrix = {
      source = "AviatrixSystems/aviatrix"
      version = "3.1.1"
    }
  }
}

provider "aviatrix" {
  controller_ip           = "x.x.x.x"
  username                = "username_here"
  password                = "password_here"
  skip_version_validation = true
  verify_ssl_certificate  = false
}

provider "aws" {
  region = "us-east-1"
  access_key = "access_key_here"
  secret_key = "secret_key_here"
}

