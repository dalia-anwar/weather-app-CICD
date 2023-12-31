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
resource "aws_security_group" "jenkins_d_sg" {
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
    from_port   = 4200    
    to_port     = 4200
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 22    
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
    Name = "deployment_ec2_sg"
  }
}

# EC2 instance
resource "aws_instance" "deployment_ec2" {
  ami                         = data.aws_ami.amazon_linux.id
  instance_type               = var.instance_type
  subnet_id                   = var.ec2_subnet_id    
  security_groups             = [aws_security_group.jenkins_w_sg.id]
  associate_public_ip_address = true
  key_name                    = var.key
  tags = {
      Name = "deployment_ec2"
    } 
  root_block_device {
    volume_type           = "gp3"
    volume_size           = var.deployment_volume_size
    delete_on_termination = false
  }

}

resource "aws_eip" "deployment_eip" {
  domain = "vpc"
  instance = aws_instance.deployment_ec2.id
  provisioner "local-exec" {
    when        = create
    on_failure  = continue
    command = "echo ${self.public_ip} >> deployment_ec2-ip.txt"
    }
}