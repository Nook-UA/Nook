resource "aws_vpc" "NookVPC" {
    cidr_block = var.vpc_cidr_block

    tags = {
        Name = "NookVPC"
    }
}

resource "aws_subnet" "NookPublicSubnet" {
    vpc_id = aws_vpc.NookVPC.id
    count = length(var.public_subnet_cidr_blocks)
    cidr_block = var.public_subnet_cidr_blocks[count.index]
    availability_zone = var.availability_zones[count.index]
    map_public_ip_on_launch = true

    tags = {
        Name = "NookPublicSubnet-${count.index}"
    }  
}

resource "aws_subnet" "NookPrivateSubnet" {
    vpc_id = aws_vpc.NookVPC.id
    count = length(var.private_subnet_cidr_blocks)
    cidr_block = var.private_subnet_cidr_blocks[count.index]
    availability_zone = var.availability_zones[count.index]
    map_public_ip_on_launch = false

    tags = {
        Name = "NookPrivateSubnet-${count.index}"   
    }
}

resource "aws_internet_gateway" "NookIGW" {
    vpc_id = aws_vpc.NookVPC.id

    tags = {
        Name = "NookIGW"
    }
}

resource "aws_eip" "NookEIP" {
    for_each = {for idx, subnet in aws_subnet.NookPrivateSubnet : idx => subnet}
    
}

resource "aws_nat_gateway" "NookNATS" {
  for_each = {for idx, subnet in aws_subnet.NookPublicSubnet : idx => subnet}
  allocation_id = aws_eip.NookEIP[each.key].id
  subnet_id = each.value.id

  tags = {
    Name = "NookNAT-${each.key}"
  }
}

resource "aws_route_table" "public_route_table" {
    vpc_id = aws_vpc.NookVPC.id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.NookIGW.id
    }

    tags = {
        Name = "NookPublicRouteTable"
    }
}

resource "aws_route_table" "private_route_table" {
    vpc_id = aws_vpc.NookVPC.id

    for_each = {for idx, subnet in aws_subnet.NookPrivateSubnet : idx => subnet}

    route {
        cidr_block = "0.0.0.0/0"
        nat_gateway_id = aws_nat_gateway.NookNATS[each.key].id
    }
    
    tags = {
        Name = "NookPrivateRouteTable-${each.key}"
    }
}

resource "aws_route_table_association" "public_route_table_association" {
    for_each = { for idx, subnet in aws_subnet.NookPublicSubnet : idx => subnet }
    subnet_id = each.value.id
    route_table_id = aws_route_table.public_route_table.id
}

resource "aws_route_table_association" "private_route_table_association" {
    for_each = { for idx, subnet in aws_subnet.NookPrivateSubnet : idx => subnet }
    subnet_id = each.value.id
    route_table_id = aws_route_table.private_route_table[each.key].id
}