#!/bin/bash

# GitLab Helm Deployment Script

echo "Deploying GitLab CE"
echo "Configuration: ClusterIP with port 9070"

# Deploy GitLab using Helm
helm upgrade --install gitlab ./gitlab \
  --namespace gitlab \
  --create-namespace \
  --timeout 600s \
  --values gitlab-values.yaml \
  --wait

echo "Deployment completed!"
echo ""
echo "🔗 To access GitLab, use port forwarding:"
echo "kubectl port-forward -n gitlab svc/gitlab-webservice-default 8080:9070"
echo ""
echo "Then access GitLab at: http://localhost:8080"
echo ""
echo "🔑 To get the root password, run:"
echo "kubectl get secret gitlab-gitlab-initial-root-password -n gitlab -o jsonpath='{.data.password}' | base64 -d"
echo ""
echo "👤 Default username: root"