variable "project_name" {
  description = "Name of the project (used for resource naming and tagging)"
  type        = string
}

variable "environment" {
  description = "Environment name (e.g. dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string

  validation {
    condition     = can(regex("^[a-zA-Z][a-zA-Z0-9-]{0,98}[a-zA-Z0-9]$", var.cluster_name))
    error_message = "cluster_name must start with a letter and contain only alphanumeric characters and hyphens."
  }
}

variable "cluster_version" {
  description = "Kubernetes version for the EKS cluster"
  type        = string
  default     = "1.30"

  validation {
    condition     = can(regex("^1\\.(2[8-9]|3[0-1])$", var.cluster_version))
    error_message = "cluster_version must be a supported EKS version (e.g. 1.28, 1.29, 1.30, 1.31)."
  }
}

variable "vpc_id" {
  description = "ID of the VPC where the cluster will be created"
  type        = string

  validation {
    condition     = can(regex("^vpc-", var.vpc_id))
    error_message = "vpc_id must be a valid VPC ID starting with 'vpc-'."
  }
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs for the worker nodes"
  type        = list(string)
}

variable "public_subnet_ids" {
  description = "List of public subnet IDs (used for control plane ENIs when public endpoint is enabled)"
  type        = list(string)
  default     = []
}

variable "endpoint_public_access" {
  description = "Whether the Kubernetes API server is publicly accessible"
  type        = bool
  default     = true
}

variable "endpoint_private_access" {
  description = "Whether the Kubernetes API server is accessible from within the VPC"
  type        = bool
  default     = true
}

variable "public_access_cidrs" {
  description = "List of CIDR blocks that can access the public API endpoint"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "node_instance_types" {
  description = "List of instance types for the managed node group"
  type        = list(string)
  default     = ["t3.small"]

  validation {
    condition     = length(var.node_instance_types) >= 1
    error_message = "At least one instance type must be specified."
  }
}

variable "node_desired_size" {
  description = "Desired number of worker nodes"
  type        = number
  default     = 1

  validation {
    condition     = var.node_desired_size >= 1 && var.node_desired_size <= 10
    error_message = "node_desired_size must be between 1 and 10."
  }
}

variable "node_min_size" {
  description = "Minimum number of worker nodes"
  type        = number
  default     = 1

  validation {
    condition     = var.node_min_size >= 1 && var.node_min_size <= 10
    error_message = "node_min_size must be between 1 and 10."
  }
}

variable "node_max_size" {
  description = "Maximum number of worker nodes"
  type        = number
  default     = 2

  validation {
    condition     = var.node_max_size >= 1 && var.node_max_size <= 10
    error_message = "node_max_size must be between 1 and 10."
  }
}

variable "node_disk_size" {
  description = "Disk size in GiB for worker nodes"
  type        = number
  default     = 20

  validation {
    condition     = var.node_disk_size >= 20 && var.node_disk_size <= 100
    error_message = "node_disk_size must be between 20 and 100 GiB."
  }
}

variable "tags" {
  description = "Additional tags to apply to all resources"
  type        = map(string)
  default     = {}
}
