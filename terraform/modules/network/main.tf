# VPC
resource "aws_vpc" "project_vpc" {
  cidr_block = var.vpc_cidr
  tags = {
    Name = "project_vpc"
  }
}

#EIP

resource "aws_eip" "master_eip" {
  instance = aws_instance.id
  domain   = "vpc"
}
resource "aws_eip_association" "jenkins_master_eip" {
  instance_id   = aws_instance.jenkins_master_ec2.id
  allocation_id = aws_eip.master_eip.id
}




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