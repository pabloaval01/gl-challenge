variable "region" {
  description = "AWS Region"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR - Primary VPC"
  type        = string
}

variable "public_subnets" {
  description = "List of Public Sunbets"
  type        = list(string)
}

variable "private_subnets" {
  description = "Lisat of Private Subnets"
  type        = list(string)
}

variable "az_count" {
  description = "Number of zones "
  type        = number
}

variable "azs" {
  description = "azs"
  type        = list(string)
}


# el modulo de vpc espera tener definida la variable private_subnet_tags:
# "Name" = format("%s-${lower(var.private_subnet_tags[count.index])}-%s", var.name, element(var.azs, count.index))
# por este motivo la llame desde el vpc.tf
variable "private_subnet_tags" {
  description = "private subnets"
  type        = map(string)
}

variable "tags" {
  description = "Resources Tags"
  type        = map(string)
}