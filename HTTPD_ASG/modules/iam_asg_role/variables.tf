variable "images_bucket_arn" {
  type = string
}

variable "logs_bucket_arn" {
  type = string
}

variable "tags" {
  type    = map(string)
  default = {}
}
