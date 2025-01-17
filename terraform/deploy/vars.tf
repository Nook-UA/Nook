variable "availability_zones" {
    type = list(string)
    default = ["eu-west-3a", "eu-west-3b"]
}

variable "vpc_cidr_block" {
    type = string
    default = "10.0.0.0/16"
}

variable "public_subnet_cidr_blocks" {
    type = list(string)
    default = ["10.0.10.0/24", "10.0.11.0/24"]
}

variable "private_subnet_cidr_blocks" {
    type = list(string)
    default = ["10.0.20.0/24", "10.0.21.0/24"]
}


#============================== Database variables ==============================

variable "db_name" {
  description = "name of database"
  type = string
  default = "nook_db"
}

variable "db_user" {
  description = "user of database"
  type = string
  default = "nook_user"
}
#TODO pass
variable "db_password" {
  description = "password of database"
  type = string
  default = "nook_passwordRafou"
}

variable "next_auth_secret" {
  description = "secret for nextauth"
  type = string
}

variable "next_public_google_maps_api_key" {
  description = "google maps api key"
  type = string
}