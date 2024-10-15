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

variable "db_subnet_cidrs" {
  description = "CIDR blocks for the database subnets"
  type        = list(string)
}

variable "elastic_ips" {
  description = "Elastic IPs for public subnets"
  type        = map(string)
}

variable "private_ips" {
  description = "Private IPs for subnets"
  type        = map(string)
}

variable "anywhere_ip" {
  description = "IP address for anywhere"
  type        = string
}

// 인스턴스 변수
variable "instance_type" {
  description = "EC2 instance type"
  type        = string
}

variable "instance_names" {
  description = "EC2 instance name"
  type        = list(string)
}

variable "instance_indexes" {
  description = "EC2 instance index"
  type        = map(number)
}

variable "ssh_keys" {
  description = "EC2 SSH access key name"
  type        = map(string)
}

variable "ec2-s3_role_name" {
  description = "The name of the role to associate with the EC2 instance"
  type        = string
}

variable "ec2-s3_iam_instance_profile_name" {
  description = "The name of the IAM instance profile to associate with the EC2 instance"
  type        = string
}

// 데이터베이스 변수
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

// 로드 밸런서 변수
variable "domain_name" {
  description = "The domain name for the ACM certificate"
  type        = string
}

// API Gateway 변수
variable "api_name" {
  description = "Name of the HTTP API"
  type        = string
}

variable "api_routes" {
    description = "List of API routes and their configurations"
    type = map(object({
        route_key     = string
        method        = string
        uri           = string
        description   = string
    }))
}
