resource "aws_db_subnet_group" "NookDBSubnetGroup" {
    name = "nook-db-subnet-group"
    subnet_ids = var.private_subnet_ids

    tags = {
      Name = "NookDBSubnetGroup"
    }
  
}

resource "aws_db_instance" "NookDB" {
    allocated_storage = 10
    storage_type = "gp2"
    engine = "postgres"
    engine_version = "16.3"
    instance_class = "db.t4g.micro"
    db_name = var.db_name
    username = var.db_user
    password = var.db_password
    db_subnet_group_name = aws_db_subnet_group.NookDBSubnetGroup.name
    publicly_accessible = false
    skip_final_snapshot = true
    parameter_group_name = "default.postgres16"
    vpc_security_group_ids = [aws_security_group.NookDBSecurityGroup.id]

    tags = {
        Name = "NookDB"
    }
}

resource "aws_security_group" "NookDBSecurityGroup" {
    name = "nook-db-security-group"
    vpc_id = var.vpc_id

    #TODO change security group rule
    ingress {
        from_port = 5432
        to_port = 5432
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
}