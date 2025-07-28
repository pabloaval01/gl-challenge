variable "region" {
  description = "AWS Region"
  type        = string
}

# variable "vpc_id" {
#   description = "ID de la VPC para el ALB"
#   type        = string
# }

variable "tags" {
  type = map(string)
}

# variable "public_subnet_ids" {
#   type        = list(string)
# }
