variable "vpc_cidr_block" {
  description = "value of vpc cidr block"
  type = string
}

variable "public_subnet_cidr_blocks" {
  description = "value of public subnet cidr blocks"
  type = list(string)
}

variable "private_subnet_cidr_blocks" {
  description = "value of private subnet cidr blocks"
  type = list(string)
}

variable "availability_zones" {
    description = "list of availability zones"
    type = list(string)
}