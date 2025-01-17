variable "private_subnet_ids" {
    description = "list of private subnet ids"
    type = list(string)
}

variable "vpc_id" {
  description = "id of the vpc"
  type = string
}