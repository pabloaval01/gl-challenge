module "vpc_nfw" {
  source = "git::https://github.com/Coalfire-CF/terraform-aws-vpc-nfw.git"

  name                      = "vpc-nfw"
  cidr                      = var.vpc_cidr
  flow_log_destination_type = "cloud-watch-logs"
  azs                       = var.azs
  public_subnets            = var.public_subnets
  private_subnets           = var.private_subnets
  private_subnet_tags       = var.private_subnet_tags

  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true

  tags = var.tags
}