locals {
  shared = terraform.workspace == "shared"
}

module "ami" {
  source = "./module/ami"
  count  = local.shared ? 0 : 1
}

module "availability_zones" {
  source = "./module/az"
}

module "gitfolio_network" {
  source               = "./module/network"
  
  vpc_cidr             = var.vpc_cidr
  public_subnet_cidrs  = var.public_subnet_cidrs
  nat_subnet_cidr      = var.nat_cidr
  private_subnet_cidrs = var.private_subnet_cidrs
  availability_zones   = module.availability_zones.az
  any_ip               = var.any_ip
  
  instance_names       = var.instance_names

  public_route_table_id = local.shared ? null : data.terraform_remote_state.shared.outputs.public_route_table_id
  vpc_id               = local.shared ? null : data.terraform_remote_state.shared.outputs.vpc_id
  igw_id               = local.shared ? null : data.terraform_remote_state.shared.outputs.igw_id
  nat_id               = local.shared ? null : data.terraform_remote_state.shared.outputs.nat_id
}

module "gitfolio_node" {
  source               = "./module/node"
  count                = local.shared ? 0 : 1

  vpc_id               = data.terraform_remote_state.shared.outputs.vpc_id
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_ids   = module.gitfolio_network.private_subnet_ids
  private_ips          = var.private_ips
  any_ip               = var.any_ip

  ami_id               = module.ami[0].amazon_linux_id
  instance_types       = var.instance_types
  instance_indexes     = var.instance_indexes
  ssh_keys             = var.ssh_keys
}

# module "gitfolio_db" {
#   source              = "./module/db/rds"
#   count               = local.shared ? 1 : 0

#   vpc_id              = module.gitfolio_network[0].vpc_id
#   db_subnet_cidrs     = var.db_subnet_cidrs
#   private_ips         = var.private_ips
#   any_ip              = var.any_ip
#   availability_zones  = module.availability_zones[0].az


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

# module "gitfolio_nosql" {
#   source             = "./module/db/nosql"
#   count              = local.shared ? 0 : 1

#   vpc_id             = data.terraform_remote_state.shared.outputs.vpc_id
#   private_subnet_ids = data.terraform_remote_state.shared.outputs.private_subnet_ids
#   private_ips        = var.private_ips
#   any_ip             = var.any_ip

#   ami_id             = module.ami[0].amazon_linux_id
#   instance_types     = var.instance_types
#   instance_indexes   = var.instance_indexes
#   ssh_keys           = var.ssh_keys
# }

module "gitfolio_alb" {
  source = "./module/LB"
  count = local.shared ? 0 : 1

  vpc_id               = data.terraform_remote_state.shared.outputs.vpc_id
  public_subnet_ids    = module.gitfolio_network.public_subnet_ids
  any_ip               = var.any_ip
  frontend_id          = module.gitfolio_node[0].frontend_id

  lb_type              = var.lb_type
  delete_protection    = var.delete_protection
  target_port          = var.target_port
  target_protocol      = var.target_protocol
  health_threshold     = var.health_threshold
  health_interval      = var.health_interval
  health_matcher       = var.health_matcher
  health_path          = var.health_path
  health_port          = var.health_port
  health_protocol      = var.health_protocol
  health_timeout       = var.health_timeout
  health_unthreshold   = var.health_unthreshold
}

# module "gitfolio_ecr" {
#   source           = "./module/ecr"
#   count            = local.shared ? 0 : 1
  
#   ecr_repo_name    = var.ecr_repo_name
#   tag_mutability   = var.tag_mutability
#   policy_tagStatus = var.policy_tagStatus
#   policy_countType = var.policy_countType
#   policy_countNum  = var.policy_countNum
# }