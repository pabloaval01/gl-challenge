terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    bucket         = "pv-demo-terraform-backend"
    key            = "vpc-nfw/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "pv-demo-terraform-lock"
  }
}

provider "aws" {
  region = var.region
} 