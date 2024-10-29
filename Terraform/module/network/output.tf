output "vpc_id" {
  description = "ID of the created VPC"
  value       = local.shared ? aws_vpc.gitfolio[0].id : null
}

output "public_subnet_ids" {
  description = "IDs of the public subnets"
  value       = local.shared ? null : aws_subnet.public[*].id
}

output "nat_subnet_id" {
  description = "ID of the nat subnet"
  value       = local.shared ? aws_subnet.nat[0].id : null
}

output "private_subnet_ids" {
  description = "IDs of the private subnets"
  value       = local.shared ? null : aws_subnet.private[*].id
}

output "igw_id" {
  description = "ID of the internet gateway"
  value       = local.shared ? aws_internet_gateway.igw[0].id : null
}

output "nat_id" {
  description = "ID of the nat gateway"
  value       = local.shared ? aws_nat_gateway.nat[0].id : null
}

output "public_route_table_id" {
  description = "ID of the public route table"
  value       = local.shared ? aws_route_table.public[0].id : null
}