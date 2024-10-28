output "vpc_id" {
  description = "ID of the created VPC"
  value       = local.shared ? module.gitfolio_network.vpc_id : null
}

output "private_subnet_ids" {
  description = "IDs of the private subnets"
  value       = local.shared ? module.gitfolio_network.private_subnet_ids : null
}

output "igw_id" {
  description = "ID of the internet gateway"
  value       = local.shared ? module.gitfolio_network.igw_id : null
}

output "nat_id" {
  description = "ID of the nat gateway"
  value       = local.shared ? module.gitfolio_network.nat_id : null
}