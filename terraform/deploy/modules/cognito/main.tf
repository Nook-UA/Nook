resource "aws_cognito_user_pool" "user_pool" {
  name = "Nook_test"

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
    Environment = "Deploy"
  }
}

resource "aws_cognito_user_pool_client" "user_pool_client" {
  name         = "NookClient"
  user_pool_id = aws_cognito_user_pool.user_pool.id

  generate_secret = true

  allowed_oauth_flows_user_pool_client = true
  allowed_oauth_flows                 = ["code"]
  allowed_oauth_scopes                = ["openid","email","profile"]

  explicit_auth_flows = [
    "ALLOW_USER_PASSWORD_AUTH",
    "ALLOW_REFRESH_TOKEN_AUTH",
  ]
  #TODO change url
  supported_identity_providers = ["COGNITO"]
  callback_urls = ["http://localhost:3000/api/auth/callback/cognito"]
  logout_urls   = ["http://localhost:3000/"]
}

resource "aws_cognito_user_pool_domain" "Nook-Domain" {
  domain       = "nook-domain"
  user_pool_id = aws_cognito_user_pool.user_pool.id
}
