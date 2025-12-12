# GitLab Community Edition Kubernetes Manifests with Kustomize

This directory contains Kubernetes manifests for deploying GitLab Community Edition using Kustomize.

## Architecture

The deployment includes:
- **GitLab CE** - Main GitLab application
- **PostgreSQL** - Database backend
- **Redis** - Caching and session storage

## Directory Structure

```
gitlab-manifests/
├── base/
│   ├── kustomization.yaml    # Base configuration
│   ├── postgresql.yaml       # PostgreSQL database
│   ├── redis.yaml           # Redis cache
│   └── gitlab.yaml          # GitLab CE with all resources
├── overlays/
│   ├── dev/                 # Development environment
│   │   ├── kustomization.yaml
│   │   ├── storage-patch.yaml      # Smaller storage
│   │   └── resources-patch.yaml    # Smaller resource limits
│   ├── staging/             # Staging environment
│   │   ├── kustomization.yaml
│   │   ├── storage-patch.yaml      # Medium storage
│   │   └── resources-patch.yaml    # Medium resources
│   └── prod/                # Production environment
│       ├── kustomization.yaml
│       ├── storage-patch.yaml      # Large storage
│       ├── resources-patch.yaml    # Large resources
│       └── replica-patch.yaml      # Multiple replicas for HA
└── README.md
```

## Deployment Options

### Development Environment

```bash
# Deploy to dev namespace
kubectl apply -k overlays/dev

# Check the deployment
kubectl get pods -n gitlab-dev
kubectl get svc -n gitlab-dev
```

### Staging Environment

```bash
# Deploy to staging namespace
kubectl apply -k overlays/staging

# Check the deployment
kubectl get pods -n gitlab-staging
kubectl get svc -n gitlab-staging
```

### Production Environment

```bash
# Deploy to prod namespace
kubectl apply -k overlays/prod

# Check the deployment
kubectl get pods -n gitlab-prod
kubectl get svc -n gitlab-prod
```

### Base Configuration

```bash
# Deploy with base configuration
kubectl apply -k base

# Check the deployment
kubectl get pods -n gitlab
kubectl get svc -n gitlab
```

## Accessing GitLab

### Internal Access

- **GitLab API**: `gitlab-service.gitlab.svc.cluster.local:80`
- **GitLab Web**: `gitlab-service.gitlab.svc.cluster.local:80`
- **GitLab SSH**: `gitlab-ssh-service.gitlab.svc.cluster.local:22`

### External Access Options

Since no Ingress is configured, use one of these methods:

1. **Port Forwarding** (for temporary access):
```bash
# Forward GitLab web interface
kubectl port-forward -n gitlab svc/gitlab-service 8080:80

# Access at http://localhost:8080
```

2. **LoadBalancer Service** (if your cluster supports it):
```bash
# Patch the service to use LoadBalancer
kubectl patch svc gitlab-service -n gitlab -p '{"spec":{"type":"LoadBalancer"}}'
```

3. **Ingress Controller** (manual setup):
Create your own Ingress resource to route traffic to the ClusterIP service

## Default Credentials

- **Username**: `root`
- **Password**: `admin123`

**⚠️ Important**: Change the default passwords before using in production!

## Environment Configuration

### Development
- PostgreSQL: 10Gi storage
- Redis: 2Gi storage
- GitLab: 20Gi storage
- GitLab: 2Gi memory request, 3Gi memory limit
- Single replica for all components

### Staging
- PostgreSQL: 30Gi storage
- Redis: 5Gi storage
- GitLab: 75Gi storage
- GitLab: 3Gi memory request, 5Gi memory limit
- Single replica for all components

### Production
- PostgreSQL: 100Gi storage
- Redis: 20Gi storage
- GitLab: 500Gi storage
- GitLab: 4Gi memory request, 8Gi memory limit
- GitLab: 2 replicas for high availability
- PostgreSQL/Redis: Single replica (consider HA setup for critical production)

## Customization

### Environment-Specific Variables

Edit the patch files in overlays/dev, overlays/staging, or overlays/prod to customize:
- Storage sizes
- Resource limits/requests
- Replica count
- Environment variables

### Changing Passwords

Update the passwords in the secret resources:
- `gitlab-secret` for GitLab root password
- `postgres-secret` for database credentials
- `redis-secret` for Redis password

Base64 encoding required:
```bash
echo "your-new-password" | base64
```

### Adding New Environments

1. Create a new directory under `overlays/`
2. Create a `kustomization.yaml` that references `../../base`
3. Add patch files as needed

## Monitoring and Maintenance

### Health Checks

All deployments include liveness and readiness probes:
- PostgreSQL: pg_isready command
- Redis: redis-cli ping
- GitLab: HTTP health check on /

### Logs

```bash
# GitLab logs
kubectl logs -n gitlab deployment/gitlab -f

# PostgreSQL logs
kubectl logs -n gitlab deployment/postgresql -f

# Redis logs
kubectl logs -n gitlab deployment/redis -f
```

### Backups

- **PostgreSQL**: Backup using pg_dump from PostgreSQL pod
- **GitLab**: Use GitLab built-in backup tools
- **Redis**: Data persists on PVC, snapshot volume for backup

## Cleanup

```bash
# Delete dev deployment
kubectl delete -k overlays/dev

# Delete staging deployment
kubectl delete -k overlays/staging

# Delete prod deployment
kubectl delete -k overlays/prod

# Delete base deployment
kubectl delete -k base
```

## Notes

- This deployment uses the cluster's default storage class
- No TLS/SSL configuration included - add as needed
- SMTP configuration is commented out in the ConfigMap
- GitLab initial startup can take 5-10 minutes
- Monitor resource usage and adjust based on your needs