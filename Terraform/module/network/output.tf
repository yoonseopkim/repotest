output "vpc_id" {
  description = "ID of the created VPC"
  value       = aws_vpc.gitfolio.id
}

output "public_subnet_ids" {
  description = "IDs of the public subnets"
  value       = aws_subnet.public[*].id
}

output "nat_subnet_id" {
  description = "ID of the nat subnet"
  value       = aws_subnet.nat.id
}

output "private_subnet_ids" {
  description = "IDs of the private subnets"
  value       = aws_subnet.private[*].id
}

output "rds_subnet_group_name" {
  description = "Name of the RDS subnet group"
  value       = aws_db_subnet_group.rds.name
}

output "igw_id" {
  description = "ID of the internet gateway"
  value       = aws_internet_gateway.igw.id
}

output "nat_id" {
  description = "ID of the nat gateway"
  value       = aws_nat_gateway.nat.id
}

output "public_route_table_id" {
  description = "ID of the public route table"
  value       = aws_route_table.public.id
}

output "security_group_ids" {
  description = "ID of the security group"
  value       = {
    "web"        = aws_security_group.web.id,
    "rds"        = aws_security_group.rds.id,
    "nosql"      = aws_security_group.nosql.id,
    "cicd"       = aws_security_group.cicd.id,
    "kubernetes" = aws_security_group.kubernetes.id
  }
}