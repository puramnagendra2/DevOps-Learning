resource "aws_vpc" "ntier" {
  cidr_block = var.ntier.cidr
  tags = {
    Name = var.ntier.name
  }
}

# Public Internet Gateway
resource "aws_internet_gateway" "public_gateway" {
  vpc_id = aws_vpc.ntier.id
  tags = {
    Name = "Public Gateway"
  }
}

# Public Subnet
resource "aws_subnet" "public_subnet" {
  vpc_id            = aws_vpc.ntier.id
  cidr_block        = var.public_subnet.cidr
  availability_zone = var.public_subnet.az
  tags = {
    Name = var.public_subnet.name
  }
}

# Public Route Table
resource "aws_route_table" "public_route" {
  vpc_id = aws_vpc.ntier.id
  route {
    cidr_block = local.anywhere
    gateway_id = aws_internet_gateway.public_gateway.id
  }
}

# Association
resource "aws_route_table_association" "public_association" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_route.id
}

# Private NAT Gateway
resource "aws_nat_gateway" "private_gateway" {
  subnet_id         = aws_subnet.private_subnet.id
  connectivity_type = "private"
  tags = {
    Name = "Private Gateway"
  }
}

# Private Subnet
resource "aws_subnet" "private_subnet" {
  vpc_id            = aws_vpc.ntier.id
  cidr_block        = var.private_subnet.cidr
  availability_zone = var.private_subnet.az
  tags = {
    Name = var.private_subnet.name
  }
}

# Private Route Table
resource "aws_route_table" "private_route" {
  vpc_id = aws_vpc.ntier.id
  route {
    cidr_block     = local.anywhere
    nat_gateway_id = aws_nat_gateway.private_gateway.id
  }
}

# Private Association
resource "aws_route_table_association" "private_association" {
  subnet_id      = aws_subnet.private_subnet.id
  route_table_id = aws_route_table.private_route.id
}