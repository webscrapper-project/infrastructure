output "vpc_id" {
  value = aws_vpc.vpc.id
}

output "vpc_cidr" {
  value = aws_vpc.vpc.cidr_block
}

output "vpc_public_subnets" {
  value = toset([for subnet in aws_subnet.public_subnets : subnet.id])
}

output "vpc_private_subnets" {
  value = toset([for subnet in aws_subnet.private_subnets : subnet.id])
}