output "cluster_name" {
  value = module.eks.cluster_name
}

output "kubeconfig_command" {
  value = "aws eks update-kubeconfig --region ${var.aws_region} --name ${module.eks.cluster_name}"
}

output "nat_public_ips" {
  value = module.vpc.nat_public_ips
}

output "vpc_id" {
  value = module.vpc.vpc_id
}
