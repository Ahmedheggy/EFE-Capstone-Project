# Application-CD

This directory contains the Kubernetes manifests for deploying the VProfile application using Kustomize.

## Structure

- `kustomization.yaml`: The main Kustomize entry point.
- `APP/`: Deployment and Service for the main application.
- `DB/`: Deployment and Service for the Database (MySQL).
- `MC/`: Deployment and Service for Memcached.
- `RMQ/`: Deployment and Service for RabbitMQ.
- `Storage/`: Persistent Volume and Claim definitions.
- `WEB/`: Deployment and Service for the Web layer (Nginx).

## Deployment

To deploy the application to your Kubernetes cluster, run:

```bash
kubectl apply -k .
```

To delete the deployment:

```bash
kubectl delete -k .
```
