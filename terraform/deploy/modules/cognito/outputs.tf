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