output "aws_region" {
  description = "AWS region of the cluster (needed by the AWS Load Balancer Controller chart)"
  value       = var.aws_region
}

output "cluster_name" {
  description = "Name of the EKS cluster"
  value       = module.eks.cluster_name
}

output "kubeconfig_command" {
  description = "Command to configure kubectl for this cluster"
  value       = "aws eks update-kubeconfig --region ${var.aws_region} --name ${module.eks.cluster_name}"
}

output "nat_public_ips" {
  description = "Public IPs of the NAT Gateway(s), useful for allowlisting outbound traffic"
  value       = module.vpc.nat_public_ips
}

output "vpc_id" {
  description = "ID of the VPC"
  value       = module.vpc.vpc_id
}

output "aws_lb_controller_role_arn" {
  description = "IAM role ARN for the AWS Load Balancer Controller ServiceAccount annotation"
  value       = module.aws_lb_controller_irsa.role_arn
}

output "ebs_csi_role_arn" {
  description = "IAM role ARN for the EBS CSI driver ServiceAccount annotation"
  value       = module.ebs_csi_irsa.role_arn
}
