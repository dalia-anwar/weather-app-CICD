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

resource "aws_key_pair" "ec2-key" {
  public_key = var.key
}
# EC2 instance
resource "aws_instance" "jenkins_worker_ec2" {
  ami                         = data.aws_ami.amazon_linux.id
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


provisioner "local-exec" {
    when        = create
    on_failure  = continue
    command = "echo ${self.public_ip} >> master_ec2-ip.txt ; echo ${aws_eip_association.jenkins_master_eip.association_id} >> master_ec2-eip.txt"
    }
}