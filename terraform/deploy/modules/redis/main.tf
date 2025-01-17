resource "aws_security_group" "elasticache_sg" {
  name        = "elasticache_sg"
  description = "Allow Redis connections from EC2"
  vpc_id = var.vpc_id

  ingress {
    from_port   = 6379
    to_port     = 6379
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # EC2 private subnet CIDR
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_elasticache_replication_group" "redis" {
  replication_group_id          = "my-redis-cluster"
  description                   = "redis replication group"
  node_type                     = "cache.t4g.micro"
  num_cache_clusters            = 2
  engine                        = "redis"
  engine_version                = "7.1"
  parameter_group_name          = "default.redis7"

  security_group_ids = [aws_security_group.elasticache_sg.id]
  subnet_group_name  = aws_elasticache_subnet_group.redis_subnet_group.id

  automatic_failover_enabled = true
}

resource "aws_elasticache_subnet_group" "redis_subnet_group" {
  name       = "redis-subnet-group"
  subnet_ids = var.private_subnet_ids

  tags = {
    Name = "redis-subnet-group"
  }
}
