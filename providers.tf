terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # backend "s3" {
  #   bucket         = "my_terraform_bucket"
  #   key            = "vpc-nfw/terraform.tfstate"
  #   region         = var.region
  #   encrypt        = true
  #   dynamodb_table = "terraform-lock" 
  # }

  # Local Backend
  backend "local" {
    path = "terraform.tfstate"
  }

}

provider "aws" {
  region = var.region
} 