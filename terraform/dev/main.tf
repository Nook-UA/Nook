output "cognito_user_pool_id" {
  value = aws_cognito_user_pool.user_pool.id
}

output "cognito_user_pool_client_id" {
  value = aws_cognito_user_pool_client.user_pool_client.id
}

output "cognito_user_pool_client_secret" {
  value = aws_cognito_user_pool_client.user_pool_client.client_secret
  sensitive = true
}

output "cognito_hosted_domain" {
  value = aws_cognito_user_pool_domain.Nook-Domain.domain
}

provider "aws" {
  region = "us-east-1"
}

# Cognito User Pool
resource "aws_cognito_user_pool" "user_pool" {
  name = "Nook_test_dev"

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
  name         = "NookClientTest_dev"
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
  domain       = "nook-domain-dev"  # This is the unique domain name you choose for your Cognito Hosted UI
  user_pool_id = aws_cognito_user_pool.user_pool.id  # Reference to your existing user pool
}



resource "aws_s3_bucket" "nook_bucket_dev" {
  bucket = "nook-bucket-dev" # Replace with your unique bucket name
  force_destroy = true

  tags = {
    Name        = "nook-bucket-dev"
    Environment = "Dev"
  }
}


resource "aws_s3_bucket_ownership_controls" "nook_bucket_ownership" {
  bucket = aws_s3_bucket.nook_bucket_dev.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_public_access_block" "public_access_block" {
  bucket = aws_s3_bucket.nook_bucket_dev.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false

}


resource "aws_s3_bucket_acl" "nook_bucket_acl" {
  depends_on = [aws_s3_bucket_ownership_controls.nook_bucket_ownership]

  bucket = aws_s3_bucket.nook_bucket_dev.id
  acl    = "private"
}

resource "aws_s3_bucket_policy" "public_bucket_policy" {
  bucket = aws_s3_bucket.nook_bucket_dev.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid       = "PublicReadGetObject",
        Effect    = "Allow",
        Principal = "*",
        Action    = "s3:GetObject",
        Resource  = "${aws_s3_bucket.nook_bucket_dev.arn}/*"
      }
    ]
  })
}

resource "aws_iam_user" "s3_full_access_user" {
  name = "s3-full-access-user"
}

resource "aws_iam_user_policy_attachment" "s3_full_access_policy" {
  user       = aws_iam_user.s3_full_access_user.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

resource "aws_iam_access_key" "s3_user_access_key" {
  user = aws_iam_user.s3_full_access_user.name
}

output "aws_access_key_id" {
  value = aws_iam_access_key.s3_user_access_key.id
}

output "aws_secret_access_key" {
  value = aws_iam_access_key.s3_user_access_key.secret
  sensitive = true
}

output "s3_bucket_name" {
  value = aws_s3_bucket.nook_bucket_dev.id
}