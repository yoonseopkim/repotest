variable "vpc_id" {
  description = "ID of the VPC"
  type        = string
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks of the public subnets"
  type        = list(string)
}

variable "private_subnet_ids" {
  description = "IDs of the private subnets"
  type        = list(string)
}

variable "instance_types" {
  description = "EC2 instance types"
  type        = map(string)
}

variable "instance_indexes" {
  description = "EC2 instance indexs"
  type        = map(number)
}

variable "ami_id" {
  description = "EC2 AMI ID"
  type        = string
}

variable "ssh_keys" {
  description = "EC2 SSH access key names"
  type        = map(string)
}

variable "private_ips" {
  description = "Private IPs for subnets"
  type        = map(string)
}

variable "any_ip" {
  description = "IP address for anywhere"
  type        = string
}