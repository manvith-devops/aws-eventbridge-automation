terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    archive = {
      source  = "hashicorp/archive"
      version = "~> 2.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

locals {
  owner      = "Manvith Katkuri"
  email      = "manvith.katkuri@techconsulting.tech"
  assignment = "Assignment-14"

  common_tags = {
    Owner      = "Manvith Katkuri"
    Email      = "manvith.katkuri@techconsulting.tech"
    Assignment = "Assignment-14"
    ManagedBy  = "Terraform"
  }
}