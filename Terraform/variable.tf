// 네트워크 변수
variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for the public subnets"
  type        = list(string)
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for the private subnets"
  type        = list(string)
}

variable "elastic_ip_names" {
  description = "Elastic IPs for public subnets"
  type        = map(string)
}

variable "any_ip" {
  description = "IP address for anywhere"
  type        = string
}

variable "instance_names" {
  description = "EC2 instance name"
  type        = list(string)
}

// 인스턴스 변수
variable "instance_types" {
  description = "EC2 instance types"
  type        = map(string)
}

variable "instance_indexes" {
  description = "EC2 instance indexs"
  type        = map(number)
}

variable "ssh_keys" {
  description = "EC2 SSH access key names"
  type        = map(string)
}

variable "private_ips" {
  description = "Private IPs for subnets"
  type        = map(string)
}

// 데이터베이스 변수
variable "db_subnet_cidrs" {
  description = "CIDR block for RDS subnet"
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

// ECR 변수
variable "ecr_repo_name" {
  description  = "Name of the ECR repository"
  type         = string
}

variable "tag_mutability" {
  description  = "Attribute which image tage is mutable"
  type         = string
}

variable "policy_tagStatus" {
  description  = "Tag status of ECR lifesycle policy"
  type         = string
}

variable "policy_countType" {
  description  = "Count type of ECR lifecycle policy"
  type         = string
}

variable "policy_countNum" {
  description  = "Count number of ECR lifecycle policy"
  type         = number
}