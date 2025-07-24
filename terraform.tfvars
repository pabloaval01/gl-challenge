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
  Environment   = "dev"
  Owner         = "Pablo"
  instance_name = "ec2-test"
}

private_subnet_tags = {
  "0" = "private-a"
  "1" = "private-b"
}
