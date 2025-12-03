# data "http" "lbc_policy" {
#   url = "https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/main/docs/install/iam_policy.json"
# }

# resource "aws_iam_policy" "lbc" {
#   name        = "${var.cluster_name}-lbc-policy" 
#   description = "Policy for AWS Load Balancer Controller for ${var.cluster_name}"
#   policy      = data.http.lbc_policy.response_body
# }

# resource "aws_iam_role" "lbc" {
#   name = "${var.cluster_name}-lbc-controller" 

#   assume_role_policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Effect = "Allow"
#         Principal = {
#           Service = "pods.eks.amazonaws.com"
#         }
#         Action = [
#           "sts:AssumeRole",
#           "sts:TagSession"
#         ]
#       }
#     ]
#   })
# }

# resource "aws_iam_role_policy_attachment" "lbc" {
#   policy_arn = aws_iam_policy.lbc.arn
#   role       = aws_iam_role.lbc.name
# }

# resource "aws_eks_pod_identity_association" "lbc" {
#   cluster_name    = aws_eks_cluster.main.name
#   namespace       = "kube-system"
#   service_account = "aws-load-balancer-controller"
#   role_arn        = aws_iam_role.lbc.arn
# }

# resource "helm_release" "lbc" {
#   name       = "aws-load-balancer-controller"
#   repository = "https://aws.github.io/eks-charts"
#   chart      = "aws-load-balancer-controller"
#   namespace  = "kube-system"

#   set {
#     name  = "clusterName"
#     value = aws_eks_cluster.main.name
#   }

#   set {
#     name  = "serviceAccount.create"
#     value = "true"
#   }

#   set {
#     name  = "serviceAccount.name"
#     value = "aws-load-balancer-controller"
#   }

#   depends_on = [
#     # 1. Wait for the Service Account Role
#     aws_eks_pod_identity_association.lbc,
#     # 2. Wait for the Cluster to be ACTIVE
#     aws_eks_cluster.main,
#     # 3. Wait for the Node Group (so CoreDNS is running)
#     aws_eks_node_group.main,
#     # 4. Wait for YOUR Admin Permissions (The most important one)
#     aws_eks_access_policy_association.admin
#   ]
# }

# data "aws_iam_policy_document" "aws_lbc" {
#   statement {
#     effect = "Allow"

#     principals {
#       type        = "Service"
#       identifiers = ["pods.eks.amazonaws.com"]
#     }

#     actions = [
#       "sts:AssumeRole",
#       "sts:TagSession"
#     ]
#   }
# }

# resource "aws_iam_role" "aws_lbc" {
#   name               = "${aws_eks_cluster.main.name}-aws-lbc"
#   assume_role_policy = data.aws_iam_policy_document.aws_lbc.json
# }

# resource "aws_iam_policy" "aws_lbc" {
#   policy = file("${path.module}/iam/AWSLoadBalancerController.json")
#   name   = "AWSLoadBalancerController"
# }

# resource "aws_iam_role_policy_attachment" "aws_lbc" {
#   policy_arn = aws_iam_policy.aws_lbc.arn
#   role       = aws_iam_role.aws_lbc.name
# }

# resource "aws_eks_pod_identity_association" "aws_lbc" {
#   cluster_name    = aws_eks_cluster.main.name
#   namespace       = "kube-system"
#   service_account = "aws-load-balancer-controller"
#   role_arn        = aws_iam_role.aws_lbc.arn
# }

# resource "helm_release" "aws_lbc" {
#   name = "aws-load-balancer-controller"

#   repository = "https://aws.github.io/eks-charts"
#   chart      = "aws-load-balancer-controller"
#   namespace  = "kube-system"
#   version    = "1.8.1"

#   set {
#     name  = "clusterName"
#     value = aws_eks_cluster.main.name
#   }

#   set {
#     name  = "serviceAccount.name"
#     value = "aws-load-balancer-controller"
#   }

#   set {
#     name  = "vpcId"
#     value = var.vpc_id
#   }


# }