output "cognito_user_pool_id" {
  value = aws_cognito_user_pool.user_pool.id
}

output "cognito_user_pool_client_id" {
  value = aws_cognito_user_pool_client.user_pool_client.id
}

output "cognito_user_pool_client_secret" {
  value = aws_cognito_user_pool_client.user_pool_client.client_secret
}

output "cognito_hosted_domain" {
  value = aws_cognito_user_pool_domain.Nook-Domain.domain
}

provider "aws" {
  region = "us-east-1"
}

# Cognito User Pool
resource "aws_cognito_user_pool" "user_pool" {
  name = "Nook_test"

  # Configuration for user attributes
  schema {
    attribute_data_type      = "String"
    name                     = "email"
    required                 = true
    mutable                  = false
  }

  auto_verified_attributes = []

  password_policy {
    minimum_length                   = 6
    require_lowercase                = false
    require_numbers                  = false
    require_symbols                  = false
    require_uppercase                = false
  }

  admin_create_user_config {
    allow_admin_create_user_only = true
  }

  tags = {
    Environment = "Dev"
  }
}

# Cognito User Pool Client
resource "aws_cognito_user_pool_client" "user_pool_client" {
  name         = "NookClientTest"
  user_pool_id = aws_cognito_user_pool.user_pool.id

  generate_secret = true

  allowed_oauth_flows_user_pool_client = true
  allowed_oauth_flows                 = ["code"]
  allowed_oauth_scopes                = ["openid","email","profile"]

  explicit_auth_flows = [
    "ALLOW_USER_PASSWORD_AUTH",
    "ALLOW_REFRESH_TOKEN_AUTH",
  ]
  supported_identity_providers = ["COGNITO"]
  callback_urls = ["http://localhost:3000/api/auth/callback/cognito"]
  logout_urls   = ["http://localhost:3000/"]
}

resource "aws_cognito_user_pool_domain" "Nook-Domain" {
  domain       = "nook-domain"  # This is the unique domain name you choose for your Cognito Hosted UI
  user_pool_id = aws_cognito_user_pool.user_pool.id  # Reference to your existing user pool
}
