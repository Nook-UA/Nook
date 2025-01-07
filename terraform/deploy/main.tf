provider "aws" {
  region = "eu-west-3"
}

module "vpc" {
  source = "./modules/vpc"
  vpc_cidr_block = var.vpc_cidr_block
  private_subnet_cidr_blocks = var.private_subnet_cidr_blocks
  public_subnet_cidr_blocks = var.public_subnet_cidr_blocks
  availability_zones = var.availability_zones
}

module "rds" {
  source = "./modules/rds"
  private_subnet_ids = module.vpc.private_subnet_ids
  vpc_id = module.vpc.vpc_id
  db_name = var.db_name
  db_user = var.db_user
  db_password = var.db_password
}

module "cognito" {
  source = "./modules/cognito"
}

module "ecs" {
  source = "./modules/ecs"
  db_name = module.rds.db_name
  db_user = module.rds.db_user
  db_password = module.rds.db_password
  db_address = module.rds.db_address
  vpc_id = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnet_ids
  public_subnet_ids = module.vpc.public_subnet_ids
  cognito_app_client_id = module.cognito.cognito_user_pool_client_id
  cognito_user_pool_id = module.cognito.cognito_user_pool_id
  aws_default_region = "eu-west-3"
  next_auth_secret = var.next_auth_secret
  next_public_google_maps_api_key = var.next_public_google_maps_api_key
  cognito_client_secret = module.cognito.cognito_user_pool_client_secret
  cognito_domain_host = module.cognito.cognito_hosted_domain
}