module "eks" {
  source = "./modules/eks"
  project_name = var.project_name
  aws_region = var.aws_region
  jenkins_and_vpc_state = data.terraform_remote_state.jenkins_and_vpc_state.outputs
  worker_node_instance_types = var.worker_node_instance_types
  worker_node_disk_size = var.worker_node_disk_size
}