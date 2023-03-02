variable "project_name" {
  description = "The Project name for VPC tags"
  type = string
}

variable "aws_region" {
  description = "AWS region"
  type = string
}

variable "vpc_cidr" {
  description = "The CIDR for VPC"
  type        = string
}
variable "public_subnets_cidr" {
  description = "Public CIDRs for VPC"
  type = list(string)
}

variable "private_subnets_cidr" {
  description = "Private CIDRs for VPC"
  type = list(string)
}

variable "availability_zones" {
  description = "Availability Zones for VPC subnets"
  type = list(string)
}
