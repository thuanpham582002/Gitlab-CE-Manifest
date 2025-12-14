#!/bin/bash

# GitLab Helm Deployment Script
# External IP: 10.254.139.26

# Set your specific kubeconfig
export KUBECONFIG=/Users/noroom113/.kube/vnet-vcluster-thuanpt.yaml

echo "Deploying GitLab CE with external IP: 10.254.139.26"
echo "Using kubeconfig: $KUBECONFIG"

# Deploy GitLab using Helm
helm upgrade --install gitlab ./gitlab \
  --namespace gitlab \
  --create-namespace \
  --timeout 600s \
  --values gitlab-values.yaml \
  --wait

echo "Deployment completed!"
echo "GitLab should be accessible at: http://gitlab.local"
echo "Or directly at: http://10.254.139.26"

# To get the initial root password:
echo "To get the root password, run:"
echo "kubectl get secret gitlab-gitlab-initial-root-password -n gitlab -o jsonpath='{.data.password}' | base64 -d"