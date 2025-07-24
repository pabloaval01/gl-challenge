region   = "us-east-1"
vpc_cidr = "10.1.0.0/16"
az_count = 2

public_subnets = [
  "10.1.0.0/24",
  "10.1.1.0/24"
]

private_subnets = [
  "10.1.2.0/24",
  "10.1.3.0/24"
]

azs = [
  "us-east-1a",
  "us-east-1b"
]

tags = {
  Environment   = "Demo"
  Owner         = "Pablo Valentino"
  Project       = "GL Challenge"
  Terraform     = "True"
  Repository    = "https://github.com/pabloaval01/gl-challenge/tree/main/VPC"
} 

private_subnet_tags = {
  "0" = "private-a"
  "1" = "private-b"
}

