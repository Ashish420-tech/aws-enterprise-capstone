module "vpc" {
  source = "../../modules/vpc"

  environment = var.environment
  vpc_cidr    = "10.0.0.0/16"

  public_subnets = [
    "10.0.1.0/24",
    "10.0.2.0/24"
  ]

  private_subnets = [
    "10.0.10.0/24",
    "10.0.11.0/24"
  ]

  availability_zones = [
    "ap-south-1a",
    "ap-south-1b"
  ]
}

module "iam_ec2" {
  source = "../../modules/iam-ec2"

  environment = var.environment
}

module "security_group" {
  source = "../../modules/security-group"

  environment = var.environment
  vpc_id      = module.vpc.vpc_id
}

module "ec2" {
  source = "../../modules/ec2"

  environment           = var.environment
  instance_type         = "t3.micro"
  subnet_id             = module.vpc.private_subnet_ids[0]
  security_group_id     = module.security_group.security_group_id
  instance_profile_name = module.iam_ec2.instance_profile_name
}
module "eks" {
  source = "../../modules/eks"

  environment         = var.environment
  cluster_name        = "${var.environment}-enterprise-eks"
  subnet_ids          = module.vpc.private_subnet_ids
  node_instance_types = ["t3.micro"]

  desired_size = 2
  min_size     = 1
  max_size     = 3
}
