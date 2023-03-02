/*==== The VPC ======*/
resource "aws_vpc" "vpc" {
  cidr_block           = var.vpc_cidr
  instance_tenancy = "default"
  enable_dns_hostnames = true
  enable_dns_support   = true
  enable_classiclink = false

  # Enable/disable ClassicLink DNS Support for the VPC.
  enable_classiclink_dns_support = false

  # Requests an Amazon-provided IPv6 CIDR block with a /56 prefix length for the VPC.
  assign_generated_ipv6_cidr_block = false

  tags = {
    Project     = var.project_name
    Name        = "${var.project_name}-${var.aws_region}-vpc"
  }
}
/*==== Subnets ======*/
/* Internet gateway for the public subnet */
resource "aws_internet_gateway" "ig" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Project     = var.project_name
    Name        = "${var.project_name}-${var.aws_region}-igw"
  }
}
/* Elastic IP for NAT */
resource "aws_eip" "nat_eip" {
  count = length(var.private_subnets_cidr)
  vpc        = true
  depends_on = [aws_internet_gateway.ig]
  tags = {
    Name: "EIP - ${count.index}"
  }
}

/* NAT */
resource "aws_nat_gateway" "nat" {
  count = length(var.private_subnets_cidr)
  allocation_id = element(aws_eip.nat_eip.*.id, count.index)
  subnet_id     = element(aws_subnet.public_subnets.*.id, count.index)
  depends_on    = [aws_internet_gateway.ig]
  tags = {
    Project     = var.project_name
    Name        = "NAT - ${count.index}"
  }
}
/* Public subnet */
resource "aws_subnet" "public_subnets" {
  vpc_id                  = aws_vpc.vpc.id
  count                   = length(var.public_subnets_cidr)
  cidr_block              = element(var.public_subnets_cidr,   count.index)
  availability_zone       = "${var.aws_region}${element(var.availability_zones,count.index)}"
  map_public_ip_on_launch = true
  tags = {
    Project     = var.project_name
    Name        = "${var.aws_region}${element(var.availability_zones, count.index)}-public-subnet"
    "kubernetes.io/cluster/${var.project_name}-cluster" = "shared"
    "kubernetes.io/role/elb" = 1
  }
}
/* Private subnet */
resource "aws_subnet" "private_subnets" {
  vpc_id                  = aws_vpc.vpc.id
  count                   = length(var.private_subnets_cidr)
  cidr_block              = element(var.private_subnets_cidr, count.index)
  availability_zone       = "${var.aws_region}${element(var.availability_zones,count.index)}"

  tags = {
    Project     = var.project_name
    Name        = "${var.aws_region}${element(var.availability_zones, count.index)}-private-subnet"
    "kubernetes.io/cluster/${var.project_name}-cluster" = "shared"
    "kubernetes.io/role/internal-elb" = 1
  }
}
/* Routing table for private subnet */
resource "aws_route_table" "private" {
  count = length(aws_nat_gateway.nat)
  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = element(aws_nat_gateway.nat.*.id, count.index)
  }

  tags = {
    Project     = var.project_name
    Name        = "${var.aws_region}-private-route-table-${count.index}"
  }
}
/* Routing table for public subnet */
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.ig.id
  }

  tags = {
    Project     = var.project_name
    Name        = "${var.aws_region}-public-route-table"
  }
}
#resource "aws_route" "public_internet_gateway" {
#  route_table_id         = aws_route_table.public.id
#  destination_cidr_block = "0.0.0.0/0"
#  gateway_id             = aws_internet_gateway.ig.id
#}
#
#resource "aws_route" "private_nat_gateway" {
#  route_table_id         = aws_route_table.private.id
#  destination_cidr_block = "0.0.0.0/0"
#  nat_gateway_id         = aws_nat_gateway.nat.id
#}

/* Route table associations */
resource "aws_route_table_association" "public" {
  count          = length(var.public_subnets_cidr)
  subnet_id      = element(aws_subnet.public_subnets.*.id, count.index)
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private" {
  count          = length(var.private_subnets_cidr)
  subnet_id      = element(aws_subnet.private_subnets.*.id, count.index)
  route_table_id = element(aws_route_table.private.*.id, count.index)
}