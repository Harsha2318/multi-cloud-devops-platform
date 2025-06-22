terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.15.0"
    }
  }
}

provider "aws" {
  region  = "ap-south-1"
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.1.2"

  name = "eks-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["ap-south-1a", "ap-south-1b"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24"]

  map_public_ip_on_launch = true

  enable_dns_hostnames = true
  enable_dns_support   = true
  enable_nat_gateway   = true
  single_nat_gateway   = true

  tags = {
    Name        = "eks-vpc"
    Environment = "dev"
  }
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "18.31.2"  # ✅ Compatible with Terraform v1.8.5

  cluster_name    = "multi-cloud-eks-renamed"
  cluster_version = "1.29"

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.public_subnets  # ✅ Public subnets for initial success on free-tier

  enable_irsa = true

  eks_managed_node_groups = {
    default = {
      instance_types = ["t3.medium"] # ✅ Free-tier compatible if credits are available
      min_size       = 1
      max_size       = 2
      desired_size   = 1

      subnet_ids = module.vpc.public_subnets  # ✅ Ensure EC2s can pull bootstrap packages
    }
  }

  create_cloudwatch_log_group = false

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}
