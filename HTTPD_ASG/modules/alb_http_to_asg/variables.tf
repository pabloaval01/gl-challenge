variable "asg_name" {
  type        = string
}

variable "tags" {
  type        = map(string)
}

variable "target_port" {
  type        = number
  default     = 443
}

