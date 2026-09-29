# EKS Networking Security Groups
resource "aws_security_group" "eks_cluster_sg" {
  name        = "${var.cluster_name}-eks-cluster-sg"
  description = "Security group for EKS cluster control plane communication with worker nodes"
  vpc_id      = module.vpc.vpc_id
  tags = merge(local.common_tags, {
    Name                                        = "${var.cluster_name}-eks-cluster-sg"
    "kubernetes.io/cluster/${var.cluster_name}" = "owned"
  })
}

resource "aws_security_group" "eks_nodes_sg" {
  name        = "${var.cluster_name}-eks-nodes-sg"
  description = "Security group for all nodes in the cluster"
  vpc_id      = module.vpc.vpc_id
  tags = merge(local.common_tags, {
    Name                                        = "${var.cluster_name}-eks-nodes-sg"
    "kubernetes.io/cluster/${var.cluster_name}" = "owned"
  })
}
