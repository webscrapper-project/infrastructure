variable "aws_region" {
  description = "AWS region"
}

variable "project_name" {
  description = "Project Name"
  default = "web-scrapper"
}

variable "terraform_jenkins_and_vpc_state_bucket_name" {
  description = "The bucket name for store terraform states for resources"
  default = "web-scrapper-states"
}

variable "terraform_jenkins_and_vpc_state_bucket_key" {
  description = "The key name for bucket to store data"
  default = "jenkins-and-vpc/terraform.tfstate"
}

variable "worker_node_instance_types" {
  description = "the instance types for worker nodes running in EC2"
  default = ["t3.small"]
}

variable "worker_node_disk_size" {
  description = "The storage for worker nodes in GB"
  default = 20
}
