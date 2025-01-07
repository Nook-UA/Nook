output "private_subnet_ids" {
    value = aws_subnet.NookPrivateSubnet.*.id
    description = "list of private subnet ids"
}

output "public_subnet_ids" {
    value = aws_subnet.NookPublicSubnet.*.id
    description = "list of public subnet ids"
}

output "vpc_id" {
    value = aws_vpc.NookVPC.id
    description = "id of vpc"
}