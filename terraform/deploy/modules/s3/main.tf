resource "aws_s3_bucket" "nook_bucket" {
  bucket = "nook-bucket"
  force_destroy = true

  tags = {
    Name        = "nook-bucket"
    Environment = "Production"
  }
}


resource "aws_s3_bucket_ownership_controls" "nook_bucket_ownership" {
  bucket = aws_s3_bucket.nook_bucket.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_public_access_block" "public_access_block" {
  bucket = aws_s3_bucket.nook_bucket.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false

}


resource "aws_s3_bucket_acl" "nook_bucket_acl" {
  depends_on = [aws_s3_bucket_ownership_controls.nook_bucket_ownership]

  bucket = aws_s3_bucket.nook_bucket.id
  acl    = "private"
}

resource "aws_s3_bucket_policy" "public_bucket_policy" {
  bucket = aws_s3_bucket.nook_bucket.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid       = "PublicReadGetObject",
        Effect    = "Allow",
        Principal = "*",
        Action    = "s3:GetObject",
        Resource  = "${aws_s3_bucket.nook_bucket.arn}/*"
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