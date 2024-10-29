variable "vpc_id" {
  description = "ID of the VPC"
  type        = string
}

variable "db_subnet_cidrs" {
  description = "CIDR blocks for the database subnets"
  type        = list(string)
}

variable "availability_zones" {
  description = "Available zones for subnet"
  type        = list(string)
}

variable identifier {
  description = "RDS instance name"
  type        = string
}

variable "engine" {
  description = "Database engine"
  type        = string
}

variable "engine_version" {
  description = "Database engine version"
  type        = string
}

variable "instance_class" {
  description = "Database instance type"
  type        = string
}

variable "allocated_storage" {
  description = "Database allocated storage"
  type        = number
}

variable "storage_type" {
  description = "Database storage type"
  type        = string
}

variable "db_name" {
  description = "Database name"
  type        = string
}

variable "db_username" {
  description = "Database username"
  type        = string
}

variable "db_password" {
  description = "Database password"
  type        = string
}

variable "private_ips" {
  description = "Private IPs for subnets"
  type        = map(string)
}

variable "any_ip" {
  description = "IP address for anywhere"
  type        = string
}
