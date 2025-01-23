# Creating AWS VPC
resource "aws_vpc" "myNetwork" {
  cidr_block = var.myVPC.cidr
  tags = {
    Name = var.myVPC.Name
  }
}

# Internet Gateway
resource "aws_internet_gateway" "myGateway" {
  vpc_id = aws_vpc.myNetwork.id
  tags = {
    Name = "${var.myGateway.Name}-igw"
  }
  depends_on = [aws_vpc.myNetwork]
}

# Creating Private Route Table
resource "aws_route_table" "private" {
  count  = local.private_subnets_count != 0 ? 1 : 0
  vpc_id = aws_vpc.myNetwork.id
  tags = {
    Name = var.private_rt.Name
  }
  depends_on = [aws_vpc.myNetwork, aws_internet_gateway.myGateway]
}

# Creating Public Route Table
resource "aws_route_table" "public" {
  count  = local.public_subnets_count != 0 ? 1 : 0
  vpc_id = aws_vpc.myNetwork.id
  route {
    cidr_block = local.anywhere
    gateway_id = aws_internet_gateway.myGateway.id
  }
  tags = {
    Name = var.public_rt.Name
  }
  depends_on = [aws_vpc.myNetwork, aws_internet_gateway.myGateway]
}

# Private Subnets
resource "aws_subnet" "private" {
  count             = local.private_subnets_count
  vpc_id            = aws_vpc.myNetwork.id
  availability_zone = var.privateSubnets[count.index].az
  cidr_block        = var.privateSubnets[count.index].cidr
  tags = {
    Name = var.privateSubnets[count.index].Name
  }
  depends_on = [aws_vpc.myNetwork]
}

# Association of Private subnets to private route table
resource "aws_route_table_association" "private_subnets_association" {
  count          = local.private_subnets_count
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[0].id
}

# Public subnets
resource "aws_subnet" "public" {
  count             = local.public_subnets_count
  vpc_id            = aws_vpc.myNetwork.id
  availability_zone = var.publicSubnets[count.index].az
  cidr_block        = var.publicSubnets[count.index].cidr
  tags = {
    Name = var.publicSubnets[count.index].Name
  }
  depends_on = [aws_vpc.myNetwork]
}

# Association of Public subnets to public route table
resource "aws_route_table_association" "public_subnets_association" {
  count          = local.public_subnets_count
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public[0].id
  depends_on     = [aws_route_table.public, aws_internet_gateway.myGateway]
}

# Security Group
resource "aws_security_group" "network_sg" {
  vpc_id      = aws_vpc.myNetwork.id
  name        = var.network_sg.name
  description = var.network_sg.description
  tags = {
    Name = var.network_sg.name
  }
  depends_on = [aws_vpc.myNetwork]
}

# Inbound Rules
resource "aws_vpc_security_group_ingress_rule" "inbound_rules" {
  count             = length(var.network_sg.inbound_rules)
  ip_protocol       = var.network_sg.inbound_rules[count.index].protocol
  security_group_id = aws_security_group.network_sg.id
  cidr_ipv4         = var.network_sg.inbound_rules[count.index].cidr
  to_port           = var.network_sg.inbound_rules[count.index].to
  from_port         = var.network_sg.inbound_rules[count.index].from
}

# Outbound Rules
resource "aws_vpc_security_group_egress_rule" "outbound_rules" {
  ip_protocol       = -1
  cidr_ipv4         = local.anywhere
  security_group_id = aws_security_group.network_sg.id
} 

# Key Pair
resource "aws_key_pair" "base" {
  key_name   = var.key_file_info.name
  public_key = file(var.key_file_info.public_key_path)
}

# Web Instance
