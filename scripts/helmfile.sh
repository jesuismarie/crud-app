#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
TF_DIR="$ROOT_DIR/infra/terraform"

TF="terraform -chdir=$TF_DIR output -raw"

AWS_ACCOUNT_ID="$($TF account_id)"
export AWS_ACCOUNT_ID

CLUSTER_NAME="$($TF cluster_name)"
export CLUSTER_NAME

AWS_REGION_NAME="$($TF aws_region)"
export AWS_REGION_NAME

AWS_VPC_ID="$($TF vpc_id)"
export AWS_VPC_ID

AWS_LOAD_BALANCER_ROLE_ARN="$($TF aws_lb_controller_role_arn)"
export AWS_LOAD_BALANCER_ROLE_ARN

AWS_EBS_ROLE_ARN="$($TF ebs_csi_role_arn)"
export AWS_EBS_ROLE_ARN

cd "$ROOT_DIR/infra/helmfile"
exec helmfile "$@"
