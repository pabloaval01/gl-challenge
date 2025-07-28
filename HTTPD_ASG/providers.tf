terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    bucket         = "globallogic-demo-terraform-backend"
    key            = "httpd_asg/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "globallogic-demo-terraform-lock"
  }
}

provider "aws" {
  region = var.region
} 