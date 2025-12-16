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

## Secret Management

We use **Sealed Secrets** to encrypt secrets so they can be safely stored in the Git repository.

### Prerequisites

1.  **Install Sealed Secrets Controller**:
    Download the controller manifest and apply it to your cluster:
    ```bash
    wget https://github.com/bitnami-labs/sealed-secrets/releases/download/v0.20.5/controller.yaml
    kubectl apply -f controller.yaml
    ```

2.  **Install `kubeseal` CLI**:
    Download and install the `kubeseal` binary:
    ```bash
    wget https://github.com/bitnami-labs/sealed-secrets/releases/download/v0.20.5/kubeseal-0.20.5-linux-amd64.tar.gz
    tar -xvf kubeseal-0.20.5-linux-amd64.tar.gz
    sudo mv kubeseal /usr/local/bin
    sudo chmod +x /usr/local/bin/kubeseal
    ```

### Creating a Sealed Secret

1.  **Create a Native Secret (Dry Run)**:
    Generate the Kubernetes Secret manifest without applying it. For example:
    ```bash
    echo -n "my-secret-value" | base64
    # Create secret.yaml with the base64 encoded value
    ```

2.  **Seal the Secret**:
    Fetch the public key and encrypt the secret:
    ```bash
    # Fetch public key
    kubeseal --fetch-cert > publickey.pem

    # Encrypt
    kubeseal --format=yaml --cert=publickey.pem < secret.yaml > sealedsecret.yaml
    ```

3.  **Deploy**:
    Commit `sealedsecret.yaml` to the repository. ArgoCD will sync it, and the Sealed Secrets controller will decrypt it into a standard Kubernetes Secret in the cluster.

    **Note**: Delete the original `secret.yaml` and `publickey.pem` after sealing. Do NOT commit the unencrypted secret.

