# VPC
resource "aws_vpc" "project_vpc" {
  cidr_block = var.vpc_cidr
  tags = {
    Name = "project_vpc"
  }
}

# internet gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.project_vpc.id
  tags = {
    Name = "project-IGW"
  }
}
# public route table 
resource "aws_route_table" "public-rt" {
  vpc_id = aws_vpc.project_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}

# Assign the public route table to public subnets
resource "aws_route_table_association" "public-rta" {
  count          = 1
  subnet_id      = aws_subnet.public_subnet_1.id
  route_table_id = aws_route_table.public-rt.id
}
# resource "aws_route_table_association" "public-rta" {
#   count          = 1
#   subnet_id      = aws_subnet.public_subnet_2.id
#   route_table_id = aws_route_table.public-rt.id
# }


resource "aws_subnet" "public_subnet_1" {
  vpc_id                  = aws_vpc.project_vpc.id
  cidr_block              = "11.0.1.0/24"
  availability_zone       =  var.subnet1_avail_zone
  map_public_ip_on_launch = true
  tags = {
    Name = "public-subnet-1"
  }
}

resource "aws_subnet" "public_subnet_2" {
  vpc_id                  = aws_vpc.project_vpc.id
  cidr_block              = "11.0.2.0/24"
  availability_zone       = var.subnet2_avail_zone
  map_public_ip_on_launch = true
  tags = {
    Name = "public-subnet-2"
  }
}

# resource "aws_subnet" "private_subnet_1" {
#   vpc_id                  = aws_vpc.project_vpc.id
#   cidr_block              = "11.0.3.0/24"
#   availability_zone       = "eu-central-1a"
#   tags = {
#     Name = "private-subnet-1"
#   }
# }

# resource "aws_subnet" "private_subnet_2" {
#   vpc_id                  = aws_vpc.project_vpc.id
#   cidr_block              = "11.0.4.0/24"
#   availability_zone       = "eu-central-1b"
#   tags = {
#     Name = "private-subnet-2"
#   }
# }