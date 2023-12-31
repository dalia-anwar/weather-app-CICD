variable "sg_vpc_id"{
    description = "VPC ID"
    type = string
}

variable "ec2_subnet_id" {
    description = "Subnet ID where instance will be launched"
    type = string
}

variable "key" {
  type        = string
  description = "SSH key pair"
}
variable "instance_type" {
  description = "The type of EC2 instance to launch"
  default     = "t3.medium"  # Set your default instance type
}

variable "deployment_volume_size" {
    description = "size of ec2 ebs volume"
    type = number
    default = "10"
}