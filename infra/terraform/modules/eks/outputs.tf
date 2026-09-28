output "cluster_id" {
  description = "The name/id of the EKS cluster"
  value       = aws_eks_cluster.cluster.id
}

output "cluster_name" {
  description = "The name of the EKS cluster"
  value       = aws_eks_cluster.cluster.name
}

output "cluster_endpoint" {
  description = "Endpoint for the Kubernetes API server"
  value       = aws_eks_cluster.cluster.endpoint
}

output "node_group_id" {
  description = "EKS node group ID"
  value       = aws_eks_node_group.cluster_node_group.id
}

output "cluster_role_arn" {
  description = "IAM role ARN of the EKS cluster"
  value       = aws_iam_role.cluster.arn
}

output "node_role_arn" {
  description = "IAM role ARN of the node group"
  value       = aws_iam_role.node.arn
}
