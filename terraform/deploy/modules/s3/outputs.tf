output "aws_access_key_id" {
  value = aws_iam_access_key.s3_user_access_key.id
}

output "aws_secret_access_key" {
  value = aws_iam_access_key.s3_user_access_key.secret
  sensitive = true
}

output "s3_bucket_name" {
  value = aws_s3_bucket.nook_bucket.id
}