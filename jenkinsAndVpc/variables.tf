variable "aws_region" {
  description = "AWS region"
}

variable "jenkins_version" {
  description = "Version of Jenkins to deploy. Must be a tag for the jenkins/jenkins image on Docker Hub."
  type = string
  default = "2.375.1-lts"
}

variable "project_name" {
  description = "Project name for usage of tags in resource"
  default     = "web-scrapper"
}

variable "vpc_cidr" {
  description = "The CIDR for VPC"
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  description = "Availability zones which subnets will create according to them"
  type = set(string)
  default = ["a","b","c"]
}

variable "private_subnets_cidr" {
  description = "The CIDR for Private subnets"
  type = set(string)
  default = ["10.0.1.0/24","10.0.2.0/24"]
}

variable "public_subnets_cidr" {
  description = "The CIDR for Public subnets"
  type = set(string)
  default = ["10.0.3.0/24","10.0.4.0/24"]
}
