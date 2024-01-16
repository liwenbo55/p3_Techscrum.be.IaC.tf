##########################################################################
# vpc
##########################################################################
resource "aws_vpc" "backend_vpc" {
  cidr_block = var.cidr_block
  tags       = { Name = "${var.project_name}-backend-vpc-${var.environment}" }
}


##########################################################################
# subnets
##########################################################################
resource "aws_subnet" "public_subnet_1" {
  vpc_id            = aws_vpc.backend_vpc.id
  cidr_block        = var.public_subnet_1_cidr_block
  tags              = { Name = "${var.project_name}-backend-public-subnet-1-${var.environment}" }
  availability_zone = var.availability_zone_1
}
resource "aws_subnet" "public_subnet_2" {
  vpc_id            = aws_vpc.backend_vpc.id
  cidr_block        = var.public_subnet_2_cidr_block
  tags              = { Name = "${var.project_name}-backend-public-subnet-2-${var.environment}" }
  availability_zone = var.availability_zone_2
}
resource "aws_subnet" "private_subnet_1" {
  count             = var.environment == "prod" || var.environment == "uat" ? 1 : 0
  vpc_id            = aws_vpc.backend_vpc.id
  cidr_block        = var.private_subnet_1_cidr_block
  tags              = { Name = "${var.project_name}-backend-private-subnet-1-${var.environment}" }
  availability_zone = var.availability_zone_1
}
resource "aws_subnet" "private_subnet_2" {
  count             = var.environment == "prod" || var.environment == "uat" ? 1 : 0
  vpc_id            = aws_vpc.backend_vpc.id
  cidr_block        = var.private_subnet_2_cidr_block
  tags              = { Name = "${var.project_name}-backend-private-subnet-2-${var.environment}" }
  availability_zone = var.availability_zone_2
}


##########################################################################
# internet gateway
##########################################################################
resource "aws_internet_gateway" "backend_igw" {
  vpc_id = aws_vpc.backend_vpc.id
  tags   = { Name = "${var.project_name}-backend_igw-${var.environment}" }
}


##########################################################################
# route tables
##########################################################################
resource "aws_route_table" "public_routetable" {
  tags   = { Name = "${var.project_name}-backend-rtb-public-${var.environment}" }
  vpc_id = aws_vpc.backend_vpc.id
  route {
    cidr_block = var.public_rt_destination
    gateway_id = aws_internet_gateway.backend_igw.id
  }
}
resource "aws_route_table" "private_routetable" {
  count  = var.environment == "prod" || var.environment == "uat" ? 1 : 0
  tags   = { Name = "${var.project_name}-backend-rtb-private-${var.environment}" }
  vpc_id = aws_vpc.backend_vpc.id
  route {
    cidr_block     = var.private_rt_destination
    nat_gateway_id = aws_nat_gateway.pub_1_nat_gateway[count.index].id
  }
}

resource "aws_route_table_association" "public_subnet_1" {
  subnet_id      = aws_subnet.public_subnet_1.id
  route_table_id = aws_route_table.public_routetable.id
}
resource "aws_route_table_association" "public_subnet_2" {
  subnet_id      = aws_subnet.public_subnet_2.id
  route_table_id = aws_route_table.public_routetable.id
}
resource "aws_route_table_association" "private_subnet_1" {
  count          = var.environment == "prod" || var.environment == "uat" ? 1 : 0
  subnet_id      = aws_subnet.private_subnet_1[count.index].id
  route_table_id = aws_route_table.private_routetable[count.index].id
}
resource "aws_route_table_association" "private_subnet_2" {
  count          = var.environment == "prod" || var.environment == "uat" ? 1 : 0
  subnet_id      = aws_subnet.private_subnet_2[count.index].id
  route_table_id = aws_route_table.private_routetable[count.index].id
}


##########################################################################
# NAT gateway
##########################################################################
# eip for NAT gateway
resource "aws_eip" "vpc_nat_gateway_eip" {
  count = var.environment == "prod" || var.environment == "uat" ? 1 : 0

  domain = "vpc"
  tags = {
    Name        = "${var.project_name}-nat-gateway-eip-${var.environment}"
    Environment = var.environment
  }
}

resource "aws_nat_gateway" "pub_1_nat_gateway" {
  count             = var.environment == "prod" || var.environment == "uat" ? 1 : 0
  subnet_id         = aws_subnet.public_subnet_1.id
  connectivity_type = "public"
  allocation_id     = aws_eip.vpc_nat_gateway_eip[count.index].id
  tags              = { Name = "${var.project_name}-nat-gateway-${var.environment}" }

  depends_on = [aws_internet_gateway.backend_igw]
}
