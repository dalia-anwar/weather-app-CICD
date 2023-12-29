variable "vpc_cidr" { 
    description = "VPC CIDR"
    type = string 
    default = "11.0.0.0/16"
    }

variable "subnet1_avail_zone" {
    description = "availability_zone"
    type = string 
    default = "eu-central-1a"
}

variable "subnet2_avail_zone" {
    description = "availability_zone"
    type = string 
    default = "eu-central-1b"
}