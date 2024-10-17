output "vpc_id" {
  description = "ID of the created VPC"
  value       = local.shared ? module.gitfolio_network[0].vpc_id : null
}

output "public_subnet_ids" {
  description = "IDs of the public subnets"
  value       = local.shared ? module.gitfolio_network[0].public_subnet_ids : null
}

output "private_subnet_ids" {
  description = "IDs of the private subnets"
  value       = local.shared ? module.gitfolio_network[0].private_subnet_ids : null
}
