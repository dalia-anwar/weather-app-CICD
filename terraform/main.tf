provider "aws" {
  profile  = var.profile
  region   = var.region
}

module "network" {
  source       = "./modules/network"
}

module "jenkins_master" {
  source            = "./modules/jenkins_master"
  sg_vpc_id         = module.network.vpc_id
  ec2_subnet_id     = module.network.public_subnet_1.id
  key               = "ec2_key"
}
module "jenkins_worker" {
  source            = "./modules/jenkins_worker"
  sg_vpc_id         = module.network.vpc_id
  ec2_subnet_id     = module.network.public_subnet_1.id
  key               = "ec2_key"

}
