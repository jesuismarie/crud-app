locals {
  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
  }

  public_subnet_tags = {
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "kubernetes.io/role/elb"                    = "1"
  }
  private_subnet_tags = {
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb"           = "1"
  }
}

data "aws_caller_identity" "current" {}

data "aws_availability_zones" "available" {
  state = "available"
}

resource "terraform_data" "az_validation" {
  lifecycle {
    precondition {
      condition = alltrue([
        for az in var.azs : contains(data.aws_availability_zones.available.names, az)
      ])
      error_message = "Invalid AZ for ${var.aws_region}. Available: ${join(", ", data.aws_availability_zones.available.names)}"
    }
  }
}

module "vpc" {
  source = "./modules/vpc"

  project_name         = var.project_name
  environment          = var.environment
  azs                  = var.azs
  vpc_cidr             = var.vpc_cidr
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  single_nat_gateway   = var.single_nat_gateway
  public_subnet_tags   = local.public_subnet_tags
  private_subnet_tags  = local.private_subnet_tags
}

module "eks" {
  source = "./modules/eks"

  project_name                = var.project_name
  environment                 = var.environment
  cluster_name                = var.cluster_name
  cluster_version             = var.cluster_version
  private_subnet_ids          = module.vpc.private_subnet_ids
  public_subnet_ids           = module.vpc.public_subnet_ids
  node_instance_types         = var.node_instance_types
  node_ami_type               = var.node_ami_type
  node_desired_size           = var.node_desired_size
  node_min_size               = var.node_min_size
  node_max_size               = var.node_max_size
  node_disk_size              = var.node_disk_size
  eks_security_group_id       = aws_security_group.eks_cluster_sg.id
  eks_nodes_security_group_id = aws_security_group.eks_nodes_sg.id
  tags                        = local.common_tags

  depends_on = [module.vpc]
}
