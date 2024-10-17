locals {
  shared = terraform.workspace == "shared"
}

module "ami" {
  source = "./module/ami"
  count = local.shared ? 0 : 1
}

module "gitfolio_network" {
  source               = "./module/network"
  count                = local.shared ? 1 : 0
  
  vpc_cidr             = var.vpc_cidr
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  any_ip               = var.any_ip
  
  instance_names       = var.instance_names
}

module "gitfolio_master" {
  source             = "./module/node"
  count              = local.shared ? 0 : 1

  vpc_id             = local.shared ? null : data.terraform_remote_state.shared.outputs.vpc_id
  private_subnet_ids = local.shared ? null : data.terraform_remote_state.shared.outputs.private_subnet_ids
  private_ips        = local.shared ? null : var.private_ips
  any_ip             = local.shared ? null : var.any_ip

  ami_id             = local.shared ? null : module.ami[0].amazon_linux_id
  instance_types     = local.shared ? null : var.instance_types
  instance_indexes   = local.shared ? null : var.instance_indexes
  ssh_keys           = local.shared ? null : var.ssh_keys
}

module "gitfolio_front" {
  source = "./module/node"
  count              = local.shared ? 0 : 1

  vpc_id             = local.shared ? null : data.terraform_remote_state.shared.outputs.vpc_id
  private_subnet_ids = local.shared ? null : data.terraform_remote_state.shared.outputs.private_subnet_ids
  private_ips        = local.shared ? null : var.private_ips
  any_ip             = local.shared ? null : var.any_ip

  ami_id             = local.shared ? null : module.ami[0].amazon_linux_id
  instance_types     = local.shared ? null : var.instance_types
  instance_indexes   = local.shared ? null : var.instance_indexes
  ssh_keys           = local.shared ? null : var.ssh_keys
}

module "gitfolio_back" {
  source = "./module/node"
  count              = local.shared ? 0 : 1

  vpc_id             = local.shared ? null : data.terraform_remote_state.shared.outputs.vpc_id
  private_subnet_ids = local.shared ? null : data.terraform_remote_state.shared.outputs.private_subnet_ids
  private_ips        = local.shared ? null : var.private_ips
  any_ip             = local.shared ? null : var.any_ip

  ami_id             = local.shared ? null : module.ami[0].amazon_linux_id
  instance_types     = local.shared ? null : var.instance_types
  instance_indexes   = local.shared ? null : var.instance_indexes
  ssh_keys           = local.shared ? null : var.ssh_keys
}

module "gitfolio_cicd" {
  source             = "./module/node"
  count              = local.shared ? 0 : 1

  vpc_id             = local.shared ? null : data.terraform_remote_state.shared.outputs.vpc_id
  private_subnet_ids = local.shared ? null : data.terraform_remote_state.shared.outputs.private_subnet_ids
  private_ips        = local.shared ? null : var.private_ips
  any_ip             = local.shared ? null : var.any_ip

  ami_id             = local.shared ? null : module.ami[0].amazon_linux_id
  instance_types     = local.shared ? null : var.instance_types
  instance_indexes   = local.shared ? null : var.instance_indexes
  ssh_keys           = local.shared ? null : var.ssh_keys
}

# module "gitfolio_db" {
#   source              = "./modules/DB"
#   count               = local.shared ? 1 : 0

#   vpc_id              = module.gitfolio_network.vpc_id
#   db_subnet_cidrs     = var.db_subnet_cidrs
#   private_ips         = var.private_ips
#   any_ip              = var.any_ip

#   identifier          = var.identifier
#   engine              = var.engine
#   engine_version      = var.engine_version
#   instance_class      = var.instance_class
#   allocated_storage   = var.allocated_storage
#   storage_type        = var.storage_type
#   db_name             = var.db_name
#   db_username         = var.db_username
#   db_password         = var.db_password
# }