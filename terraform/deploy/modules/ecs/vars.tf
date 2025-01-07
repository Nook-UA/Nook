variable "vpc_id" {
    description = "id of vpc"
    type = string
}

variable "public_subnet_ids" {
    description = "list of public subnet ids"
    type = list(string)
}

variable "private_subnet_ids" {
    description = "list of private subnet ids"
    type = list(string)
}

variable "db_address" {
    description = "address of database"
    type = string
}

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

variable "aws_default_region" {
    description = "default region of aws"
    type = string
}

variable "cognito_user_pool_id" {
    description = "id of cognito user pool"
    type = string
}

variable "cognito_app_client_id" {
    description = "id of cognito app client"
    type = string
}

variable "next_auth_secret" {
    description = "secret of next auth"
    type = string
}

variable "cognito_client_secret" {
    description = "secret of cognito client"
    type = string
}

variable "cognito_domain_host" {
  description = "host of cognito domain"
  type = string
}

variable "next_public_google_maps_api_key" {
  description = "google maps api key"
  type = string
}