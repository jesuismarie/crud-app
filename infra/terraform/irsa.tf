module "aws_lb_controller_irsa" {
  source = "./modules/irsa"

  role_name         = "${var.cluster_name}-aws-lb-controller"
  oidc_provider_arn = module.eks.oidc_provider_arn
  oidc_provider_url = module.eks.oidc_provider_url
  namespace         = "kube-system"
  service_account   = var.lb_sa
  policy_json       = file("${path.module}/policies/aws-load-balancer-controller.json")
}

module "ebs_csi_irsa" {
  source = "./modules/irsa"

  role_name           = "${var.cluster_name}-ebs-csi-controller"
  oidc_provider_arn   = module.eks.oidc_provider_arn
  oidc_provider_url   = module.eks.oidc_provider_url
  namespace           = "kube-system"
  service_account     = var.ebs_sa
  managed_policy_arns = ["arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"]
}
