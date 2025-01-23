# Creating AWS VPC
resource "aws_vpc" "network" {
  cidr_block = var.vpc_network.cidr
  tags = {
    Name = var.vpc_network.Name
  }
}

# Creating Subnets
resource "aws_subnet" "subnets" {
  count             = length(var.subnets_info)
  vpc_id            = aws_vpc.network.id
  availability_zone = var.subnets_info[count.index].az
  cidr_block        = var.subnets_info[count.index].cidr
  depends_on        = [aws_vpc.network]
  tags = {
    Name = var.subnets_info[count.index].Name
  }
}
