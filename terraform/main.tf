provider "aws" {
  region   = var.region
}

module "network" {
  source       = "./modules/network"
}

module "jenkins_master" {
  source            = "./modules/jenkins_master"
  sg_vpc_id         = module.network.vpc_id
  ec2_subnet_id     = module.network.public_subnet1_id
  key               = "ec2_key"
  master_az         = "eu-central-1a"
}
module "jenkins_worker" {
  source            = "./modules/jenkins_worker"
  sg_vpc_id         = module.network.vpc_id
  ec2_subnet_id     = module.network.public_subnet1_id
  key               = "ec2_key"

}
module "ecr" {
  source            = "./modules/ecr"
}
