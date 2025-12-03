resource "aws_iam_role" "argo_updater" {
  name = "${var.cluster_name}-argo-updater"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "pods.eks.amazonaws.com"
        }
        Action = [
          "sts:AssumeRole",
          "sts:TagSession"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "argo_updater_ecr" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.argo_updater.name
}

resource "aws_eks_pod_identity_association" "argo_updater" {
  cluster_name    = aws_eks_cluster.main.name
  namespace       = "argocd"
  service_account = "argo-image-updater"
  role_arn        = aws_iam_role.argo_updater.arn
}


resource "helm_release" "argocd" {
  name             = "argocd"
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  namespace        = "argocd"
  create_namespace = true
  version          = "7.7.0" # Pinning version for stability

  # Configure ArgoCD to run on NodePort (Bypass AWS LoadBalancer restriction)
  set {
    name  = "server.service.type"
    value = "NodePort"
  }
  set {
    name  = "server.service.nodePorts.http"
    value = "30081" # Access via http://<NODE_IP>:30080
  }
  set {
    name  = "server.service.nodePorts.https"
    value = "30444" # Access via https://<NODE_IP>:30443
  }
  
  # Disable TLS on the pod level to simplify NodePort access (Optional but recommended for testing)
  set {
    name  = "server.extraArgs"
    value = "{--insecure}"
  }

  depends_on = [
    aws_eks_cluster.main,
    aws_eks_node_group.main,
    aws_eks_access_policy_association.admin
  ]
}


resource "helm_release" "updater" {
  name       = "argo-image-updater"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-image-updater"
  namespace  = "argocd"
  version    = "0.11.0"

  # Link to the Service Account we created via Pod Identity
  set {
    name  = "serviceAccount.create"
    value = "true"
  }
  set {
    name  = "serviceAccount.name"
    value = "argo-image-updater"
  }
  
  # Configure ECR settings
  set {
    name  = "config.registries[0].name"
    value = "ECR"
  }
  set {
    name  = "config.registries[0].api_url"
    value = "https://${data.aws_caller_identity.current.account_id}.dkr.ecr.${var.aws_region}.amazonaws.com"
  }
  set {
    name  = "config.registries[0].prefix"
    value = "${data.aws_caller_identity.current.account_id}.dkr.ecr.${var.aws_region}.amazonaws.com"
  }
  set {
    name  = "config.registries[0].ping"
    value = "yes"
  }
  set {
    name  = "config.registries[0].credentials"
    value = "ext:/scripts/ecr-login.sh" # Uses the IAM Role/Pod Identity automatically
  }
  set {
    name  = "config.registries[0].credsexpire"
    value = "10h"
  }

  depends_on = [
    helm_release.argocd,
    aws_eks_pod_identity_association.argo_updater
  ]
}