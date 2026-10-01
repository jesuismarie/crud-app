#!/bin/bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TF_DIR="$ROOT_DIR/infra/terraform"

if [[ ! -f "$TF_DIR/policies/aws-load-balancer-controller.json" ]]; then
  echo "Missing $TF_DIR/policies/aws-load-balancer-controller.json - see $TF_DIR/policies/README.md"
  exit 1
fi

cd "$TF_DIR"
terraform init && terraform apply

eval "$(terraform output -raw kubeconfig_command)"
