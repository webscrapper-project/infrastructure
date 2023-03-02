provider "helm" {
  kubernetes {
    host                   = aws_eks_cluster.back-end-eks-cluster.endpoint
    cluster_ca_certificate = base64decode(aws_eks_cluster.back-end-eks-cluster.certificate_authority[0].data)

    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      args        = ["eks", "get-token", "--cluster-name", aws_eks_cluster.back-end-eks-cluster.id]
      command     = "aws"
    }
  }
}

resource "helm_release" "loadbalancer_controller" {
  depends_on = [
    aws_iam_role.aws_load_balancer_controller,
    aws_eks_node_group.worker-node-group,
    aws_iam_role_policy_attachment.aws_load_balancer_controller_attach
  ]
  name       = "aws-load-balancer-controller"

  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"

  namespace = "kube-system"

  set {
    name = "image.repository"
    value = var.load-balancer-image-url
  }

  set {
    name  = "serviceAccount.create"
    value = "true"
  }

  set {
    name  = "serviceAccount.name"
    value = "aws-load-balancer-controller"
  }

  set {
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = aws_iam_role.aws_load_balancer_controller.arn
  }

  set {
    name  = "vpcId"
    value = var.jenkins_and_vpc_state.vpc_id
  }

  set {
    name  = "region"
    value = var.aws_region
  }

  set {
    name  = "clusterName"
    value = aws_eks_cluster.back-end-eks-cluster.id
  }

}