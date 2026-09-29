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
  public_subnet_tags   = var.public_subnet_tags
  private_subnet_tags  = var.private_subnet_tags
  cluster_name         = var.cluster_name
}
