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


resource "helm_release" "argocd_v2" {
  name             = "argocd"
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  namespace        = "argocd"
  create_namespace = true
  version          = "7.7.0" # Pinning version for stability

  # Configure ArgoCD to run on NodePort (Bypass AWS LoadBalancer restriction)
  set {
    name  = "server.service.type"
    value = "LoadBalancer"
  }

  # 2. DO NOT add "aws-load-balancer-type" annotation.
  # By omitting it, AWS defaults to Classic Load Balancer (CLB).

  # 3. Terminate TLS at the LB (Optional, but standard for CLB)
  # This maps Port 80 on the LB to the HTTP port on the container
  set {
    name  = "server.service.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-connection-draining-enabled"
    value = "true"
  }

  # 4. Remove NodePort settings (Let AWS handle the ports)
  # (Make sure you don't have server.service.nodePorts set)

  # 5. Run in insecure mode (since we don't have a domain cert yet)
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
    helm_release.argocd_v2,
    aws_eks_pod_identity_association.argo_updater
  ]
}