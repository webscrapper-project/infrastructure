resource "aws_eks_cluster" "back-end-eks-cluster" {
  name = "${var.project_name}-cluster"
  role_arn = aws_iam_role.eks-iam-role.arn

  vpc_config {
    endpoint_private_access = false
    endpoint_public_access = true
    subnet_ids = concat(
      tolist(var.jenkins_and_vpc_state.private_subnets),
      tolist(var.jenkins_and_vpc_state.public_subnets)
    )
  }

  depends_on = [
    aws_iam_role_policy_attachment.AmazonEKSClusterPolicy
  ]
}

resource "aws_eks_node_group" "worker-node-group" {
  cluster_name  = aws_eks_cluster.back-end-eks-cluster.name
  node_group_name = "${aws_eks_cluster.back-end-eks-cluster.name}-workernodes"
  node_role_arn  = aws_iam_role.worker_nodes.arn
  subnet_ids   = var.jenkins_and_vpc_state.private_subnets
  instance_types = var.worker_node_instance_types
  ami_type = "AL2_x86_64"
  capacity_type = "ON_DEMAND"
  disk_size = var.worker_node_disk_size

  scaling_config {
    desired_size = 2
    max_size   = 3
    min_size   = 1
  }

  depends_on = [
    aws_iam_role_policy_attachment.AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.AmazonEC2ContainerRegistryReadOnly,
  ]
}