variable "role_name" {
  description = "Name of the IAM role"
  type        = string
}

variable "oidc_provider_arn" {
  description = "ARN of the EKS cluster OIDC provider"
  type        = string
}

variable "oidc_provider_url" {
  description = "URL of the EKS cluster OIDC provider (with or without https://)"
  type        = string
}

variable "namespace" {
  description = "Kubernetes namespace of the ServiceAccount"
  type        = string
}

variable "service_account" {
  description = "Kubernetes ServiceAccount name allowed to assume the role"
  type        = string
}

variable "policy_json" {
  description = "Optional custom IAM policy document (JSON) to create and attach"
  type        = string
  default     = null
}

variable "managed_policy_arns" {
  description = "Optional list of existing IAM policy ARNs to attach"
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Module specific tags to apply to all resources"
  type        = map(string)
  default     = {}
}
