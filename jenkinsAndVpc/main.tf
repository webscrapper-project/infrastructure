//Create VPC
module "vpc" {
  source = "./modules/vpc"

  availability_zones   = var.availability_zones
  aws_region           = var.aws_region
  private_subnets_cidr = var.private_subnets_cidr
  project_name         = var.project_name
  public_subnets_cidr  = var.public_subnets_cidr
  vpc_cidr             = var.vpc_cidr
}

//Create ECS cluster, service and task for Jenkins
module "ecs-jenkins" {
  source = "./modules/ecs-jenkins"

  aws_region           = var.aws_region
  private_subnets      = module.vpc.vpc_private_subnets
  project_name         = var.project_name
  public_subnets       = module.vpc.vpc_public_subnets
  vpc_id               = module.vpc.vpc_id
  private_subnet_count = local.private_subnet_count
  public_subnet_count  = local.public_subnet_count
  jenkins_version      = var.jenkins_version
  repo_url             = module.ecr.jenkins-repo-url
  repo_token           = module.ecr.ecr-token
}

//module "ecr"
module "ecr" {
  source = "./modules/ecr"
}

