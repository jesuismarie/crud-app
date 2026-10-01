# IAM policies

`aws-load-balancer-controller.json` is the official IAM policy published by the AWS Load Balancer Controller project. Download it once (and commit it):

```bash
curl -fsSL -o infra/terraform/policies/aws-load-balancer-controller.json \
  https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/main/docs/install/iam_policy.json
```

When you upgrade the controller Helm chart, re-download the policy from the matching release tag.
