# ============================== Database variables ==============================

variable "db_name" {
  description = "name of database"
  type = string
}

variable "db_user" {
  description = "user of database"
  type = string
}

variable "db_password" {
  description = "password of database"
  type = string

}

# ============================== Vpc variables ==============================

variable "private_subnet_ids" {
  description = "list of private subnet ids"
  type = list(string)
}

variable "vpc_id" {
  description = "id of vpc"
  type = string
}

# variable "cluster_ec2_security_groups" {
#   description = "list of cluster ec2 security groups"
#   type = list(string)
# }