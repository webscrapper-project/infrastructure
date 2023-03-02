locals {
  azs = [for zone in var.availability_zones : "${var.aws_region}${zone}"]
  private_subnet_count = length(var.private_subnets_cidr)
  public_subnet_count = length(var.public_subnets_cidr)
}