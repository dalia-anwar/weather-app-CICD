variable "sg_vpc_id"{
    description = "VPC ID"
    type = string
}

variable "ec2_subnet_id" {
    description = "Subnet ID where instance will be launched"
    type = string
}


variable "instance_type" {
  description = "The type of EC2 instance to launch"
  default     = "t2.micro"  # Set your default instance type
}

variable "jenkins_master_volume_size" {
    description = "size of ec2 ebs volume"
    type = number
    default = "10"
}
variable "key" {
  type        = string
  description = "SSH key pair"
}