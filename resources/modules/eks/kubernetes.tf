provider "kubernetes" {
  host                   = aws_eks_cluster.back-end-eks-cluster.endpoint
  cluster_ca_certificate = base64decode(aws_eks_cluster.back-end-eks-cluster.certificate_authority[0].data)
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    args        = ["eks", "get-token", "--cluster-name", aws_eks_cluster.back-end-eks-cluster.id]
    command     = "aws"
  }
}

resource "kubernetes_namespace" "namespace-dev" {
  metadata {
    name = "dev"
  }
}

resource "kubernetes_namespace" "namespace-prod" {
  metadata {
    name = "prod"
  }
}

resource "kubernetes_namespace" "postgres-dev" {
  metadata {
    name = "postgres-dev"
  }
}

resource "kubernetes_namespace" "postgres-prod" {
  metadata {
    name = "postgres-dev"
  }
}
