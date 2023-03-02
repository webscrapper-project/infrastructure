variable "project_name" {
  description = "Project Name"
}

variable "aws_region" {
  description = "AWS region"
}

variable "jenkins_and_vpc_state" {
  description = "Remote state outputs for jenkins and vpc"
}

variable "worker_node_instance_types" {
  description = "the instance types for worker nodes running in EC2"
}

variable "worker_node_disk_size" {
  description = "The storage for worker nodes in GB"
}

variable "load-balancer-image-url" {
  default = "602401143452.dkr.ecr.eu-central-1.amazonaws.com/amazon/aws-load-balancer-controller"
}