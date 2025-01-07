output "db_name" {
  value = aws_db_instance.NookDB.db_name
  description = "name of database"
}

output "db_user" {
  value = aws_db_instance.NookDB.username
  description = "user of database"
}

output "db_password" {
  value = aws_db_instance.NookDB.password
  description = "password of database"
}

output "db_address" {
  value = aws_db_instance.NookDB.address
  description = "address of database"
}