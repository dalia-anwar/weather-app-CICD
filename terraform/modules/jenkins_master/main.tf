#AMI
#SG
#AWS Instance


# EC2 AMI
data "aws_ami" "amazon_linux" {
  most_recent = true

  filter {
    name   = "name"
    values = ["al2023-ami-2023.3.20231218.0-kernel-6.1-x86_64"]
  }
  
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
  owners = ["137112412989"]
}

# EC2 security group
resource "aws_security_group" "jenkins_m_sg" {
  vpc_id = var.sg_vpc_id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8080     # open port (8080) for jenkins
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22    # allow ssh to configure instance with ansible
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "jenkins_master_ec2_sg"
  }
}

# resource "aws_key_pair" "ec2-key" {
#   public_key = var.key
# }

resource "aws_eip_association" "eip_assoc" {
  instance_id   = aws_instance.jenkins_master_ec2.id
  allocation_id = aws_eip.example.id
}

resource "aws_instance" "web" {
  ami               = "ami-21f78e11"
  availability_zone = "us-west-2a"
  instance_type     = "t2.micro"

  tags = {
    Name = "HelloWorld"
  }
}

resource "aws_eip" "example" {
  domain = "vpc"
}
# EC2 instance
resource "aws_instance" "jenkins_master_ec2" {
  ami                         = data.aws_ami.amazon_linux.id
  availability_zone           = var.master_az
  instance_type               = var.instance_type
  subnet_id                   = var.ec2_subnet_id    
  security_groups             = [aws_security_group.jenkins_m_sg.id]
  associate_public_ip_address = true
  key_name                    = var.key
  tags = {
      Name = "jenkins_master_EC2"
    } 
  root_block_device {
    volume_type           = "gp3"
    volume_size           = var.jenkins_master_volume_size
    delete_on_termination = false
  }

# provisioner "local-exec" {
#     when        = create
#     on_failure  = continue
#     command = "echo ${self.public_ip} >> master_ec2-ip.txt ; echo ${aws_eip.master_eip} >> master_ec2-eip.txt"
#     }
#     depends_on = [aws_eip.master_eip]
}

#EIP


# resource "aws_eip_association" "jenkins_master_eip" {
#   instance_id   = aws_instance.jenkins_master_ec2.id
#   allocation_id = aws_eip.master_eip.id
#   depends_on = [aws_instance.jenkins_master_ec2, aws_eip.master_eip]
# }
