locals {
  controller_docker_image = format("%s:%s",var.repo_url,var.jenkins_version)
}

variable "aws_region" {
  description = "AWS region"
}

variable "project_name" {
  description = "Project name for usage of tags in resource"
}

################################################################################################
################################################################################################
#################### REQUIRED parameters
variable "private_subnets" {
  description = "Private subnets to deploy Jenkins and the internal NLB"
  type        = set(string)
}

variable "public_subnets" {
  description = "Public subnets to deploy the load balancer"
  type        = set(string)
}

variable "private_subnet_count" {
  description = "The count should be defined because of for_each functions, otherwise it will give error: the 'for_each' set includes values derived from resource attributes that cannot be determined until apply, and so terraform cannot determine the full set of keys that will identify the instances of this resource."
}

variable "public_subnet_count" {
  description = "The count should be defined because of for_each functions, otherwise it will give error: the 'for_each' set includes values derived from resource attributes that cannot be determined until apply, and so terraform cannot determine the full set of keys that will identify the instances of this resource."
}

variable "vpc_id" {
  description = "The VPC id"
  type        = string
}

variable "jenkins_version" {
  description = "Version of Jenkins to deploy. Must be a tag for the jenkins/jenkins image on Docker Hub."
  type = string
}

variable "repo_url" {
  description = "URL of the Docker repository to push the built Jenkins image to."
  type = string
}

variable "repo_token" {
  description = "Access token for the Docker repository to push the built Jenkins image to."
}
#################### General variables

variable "fargate_platform_version" {
  description = "Fargate platform version to use. Must be >= 1.4.0 to be able to use Fargate"
  type        = string
  default     = "1.4.0"
}

variable "default_tags" {
  description = "Default tags to apply to the resources"
  type        = map(string)
  default = {
    Application = "Jenkins"
    Environment = "test"
    Terraform   = "True"
  }
}

#################### Jenkins variables
variable "controller_cpu_memory" {
  description = "CPU and memory for Jenkins controller. Note that all combinations are not supported with Fargate."
  type = object({
    memory = number
    cpu    = number
  })
  default = {
    memory = 2048
    cpu    = 1024
  }
}

variable "agents_cpu_memory" {
  description = "CPU and memory for the agent example. Note that all combinations are not supported with Fargate."
  type = object({
    memory = number
    cpu    = number
  })
  default = {
    memory = 2048
    cpu    = 1024
  }
}

variable "controller_deployment_percentages" {
  description = "The Min and Max percentages of Controller instance to keep when updating the service. See https://docs.aws.amazon.com/AmazonECS/latest/developerguide/update-service.html"
  type = object({
    min = number
    max = number
  })
  default = {
    min = 0
    max = 100
  }
}

variable "controller_log_retention_days" {
  description = "Retention days for Controller log group"
  type        = number
  default     = 14
}

variable "agents_log_retention_days" {
  description = "Retention days for Agents log group"
  type        = number
  default     = 5
}

variable "agent_docker_image" {
  type        = string
  description = "Docker image to use for the example agent. See: https://hub.docker.com/r/jenkins/inbound-agent/"
  default     = "elmhaidara/jenkins-alpine-agent-aws:latest-alpine" //TODO create image for jenkins-agnets according to docker/DockerFile.agent and paste url here
}

variable "controller_listening_port" {
  type        = number
  default     = 8080
  description = "Jenkins container listening port"
}

variable "controller_jnlp_port" {
  type        = number
  default     = 50000
  description = "JNLP port used by Jenkins agent to communicate with the controller"
}

variable "controller_java_opts" {
  type        = string
  description = "JENKINS_OPTS to pass to the controller"
  default     = ""
}

variable "controller_num_executors" {
  type        = number
  description = "Set this to a number > 0 to be able to build on controller (NOT RECOMMENDED)"
  default     = 0
}

variable "controller_docker_user_uid_gid" {
  type        = number
  description = "Jenkins User/Group ID inside the container. One should consider using access point."
  default     = 0 # root
}

variable "efs_performance_mode" {
  type        = string
  description = "EFS performance mode. Valid values: generalPurpose or maxIO"
  default     = "generalPurpose"
}

variable "efs_throughput_mode" {
  type        = string
  description = "Throughput mode for the file system. Valid values: bursting, provisioned. When using provisioned, also set provisioned_throughput_in_mibps"
  default     = "bursting"
}

variable "efs_provisioned_throughput_in_mibps" {
  type        = number
  description = "The throughput, measured in MiB/s, that you want to provision for the file system. Only applicable with throughput_mode set to provisioned."
  default     = null
}

variable "efs_burst_credit_balance_threshold" {
  type        = number
  description = "Threshold below which the metric BurstCreditBalance associated alarm will be triggered. Expressed in bytes"
  default     = 1154487209164 # half of the default credits
}

variable "allowed_ip_addresses" {
  description = "List of allowed IP addresses to access the controller from the ALB"
  type        = set(string)
  default     = ["0.0.0.0/0"]
}
