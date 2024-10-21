locals {
  shared = terraform.workspace == "shared"
}

module "ami" {
  source = "./module/ami"
  count  = local.shared ? 0 : 1
}

module "availability_zones" {
  source = "./module/az"
  count  = local.shared ? 1 : 0
}

module "gitfolio_network" {
  source               = "./module/network"
  count                = local.shared ? 1 : 0
  
  vpc_cidr             = var.vpc_cidr
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  availability_zones   = module.availability_zones[0].az
  any_ip               = var.any_ip
  
  instance_names       = var.instance_names
}

module "gitfolio_node" {
  source             = "./module/node"
  count              = local.shared ? 0 : 1

  vpc_id             = data.terraform_remote_state.shared.outputs.vpc_id
  private_subnet_ids = data.terraform_remote_state.shared.outputs.private_subnet_ids
  private_ips        = var.private_ips
  any_ip             = var.any_ip

  ami_id             = module.ami[0].amazon_linux_id
  instance_types     = var.instance_types
  instance_indexes   = var.instance_indexes
  ssh_keys           = var.ssh_keys
}

module "gitfolio_db" {
  source              = "./module/db/rds"
  count               = local.shared ? 1 : 0

  vpc_id              = module.gitfolio_network[0].vpc_id
  db_subnet_cidrs     = var.db_subnet_cidrs
  private_ips         = var.private_ips
  any_ip              = var.any_ip
  availability_zones  = module.availability_zones[0].az

  identifier          = var.identifier
  engine              = var.engine
  engine_version      = var.engine_version
  instance_class      = var.instance_class
  allocated_storage   = var.allocated_storage
  storage_type        = var.storage_type
  db_name             = var.db_name
  db_username         = var.db_username
  db_password         = var.db_password
}

module "gitfolio_nosql" {
  source             = "./module/db/nosql"
  count              = local.shared ? 0 : 1

  vpc_id             = data.terraform_remote_state.shared.outputs.vpc_id
  private_subnet_ids = data.terraform_remote_state.shared.outputs.private_subnet_ids
  private_ips        = var.private_ips
  any_ip             = var.any_ip

  ami_id             = module.ami[0].amazon_linux_id
  instance_types     = var.instance_types
  instance_indexes   = var.instance_indexes
  ssh_keys           = var.ssh_keys
}

module "gitfolio_ecr" {
  source           = "./module/ecr"
  count            = local.shared ? 0 : 1
  
  ecr_repo_name    = var.ecr_repo_name
  tag_mutability   = var.tag_mutability
  policy_tagStatus = var.policy_tagStatus
  policy_countType = var.policy_countType
  policy_countNum  = var.policy_countNum
}