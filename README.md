# EFE Capstone Project

This repository contains the source code, deployment manifests, and infrastructure configuration for the **VProfile** application. VProfile is a multi-tier Java web application that demonstrates a modern DevOps workflow, including containerization, orchestration, and infrastructure as code.

## Architecture

The VProfile application consists of the following services:
- **Nginx**: Web server and reverse proxy.
- **Tomcat**: Application server hosting the Java artifact.
- **RabbitMQ**: Message broker for asynchronous communication.
- **Memcached**: Caching service for database queries.
- **MySQL**: Relational database for persistent storage.

![Architecture Diagram](.images/Arch.png)

## Components

The project is organized into the following directories:

- **[Application-CI](./Application-CI/README.md)**: Contains the Java application source code and Docker build configuration.
- **[Application-CD](./Application-CD/README.md)**: Contains the Kubernetes manifests for deploying the application using Kustomize and ArgoCD.
- **[Terrafrom](./Terrafrom/README.md)**: Contains the Terraform configuration for provisioning AWS infrastructure.

## Prerequisites

Before running the application, ensure you have the following tools installed:

- **Docker**: For building container images.
- **Kubernetes CLI (kubectl)**: For interacting with the cluster.
- **Terraform**: For provisioning infrastructure.
- **AWS CLI**: For managing AWS resources.

## Automated Workflow

The application deployment is fully automated using a CI/CD pipeline:

1.  **Infrastructure Provisioning**: GitHub Actions triggers Terraform to provision the EKS cluster and other AWS resources.
2.  **Continuous Integration (CI)**: GitHub Actions builds the Docker image and pushes it to Amazon ECR.
3.  **Continuous Delivery (CD)**: ArgoCD watches the repository for changes and automatically syncs the application state to the EKS cluster.

### Running Application
![Running Application](.images/the%20running%20app.jpeg)

For detailed instructions on **Secret Management** using Sealed Secrets, refer to the [Application-CD README](./Application-CD/README.md#secret-management).

## Monitoring & CD

### Monitoring
The project includes monitoring configurations.
![Monitoring Dashboard](.images/Monitoring.jpeg)

### ArgoCD
We use ArgoCD for GitOps-based continuous delivery.
![ArgoCD Interface](.images/argocd.png)
