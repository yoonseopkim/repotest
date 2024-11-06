locals {
  shared = terraform.workspace == "shared"
}

module "ami" {
  source = "./module/AMI"
  count  = local.shared ? 0 : 1
}

module "availability_zones" {
  source = "./module/AZ"
}

module "gitfolio_network" {
  source               = "./module/network"
  
  vpc_cidr              = var.vpc_cidr
  public_subnet_cidrs   = var.public_subnet_cidrs
  nat_subnet_cidr       = var.nat_cidr
  private_subnet_cidrs  = var.private_subnet_cidrs
  availability_zones    = module.availability_zones.az
  any_ip                = var.any_ip

  instance_names        = var.instance_names

  public_route_table_id = local.shared ? null : data.terraform_remote_state.shared.outputs.public_route_table_id
  vpc_id                = local.shared ? null : data.terraform_remote_state.shared.outputs.vpc_id
  igw_id                = local.shared ? null : data.terraform_remote_state.shared.outputs.igw_id
  nat_id                = local.shared ? null : data.terraform_remote_state.shared.outputs.nat_id
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
  module_indexes       = var.module_indexes

  on_front             = 1
  on_back              = 4
  on_ai                = 1
  on_master            = 0
  on_jenkins           = 0
  on_argo              = 0
  on_ingress           = 0
}

module "gitfolio_db" {
  source             = "./module/DB"
  count              = local.shared ? 0 : 1

  vpc_id             = data.terraform_remote_state.shared.outputs.vpc_id
  private_subnet_ids = module.gitfolio_network.private_subnet_ids
  private_ips        = var.private_ips
  any_ip             = var.any_ip

  ami_id             = module.ami[0].amazon_linux_id
  instance_types     = var.instance_types
  instance_indexes   = var.instance_indexes
  ssh_keys           = var.ssh_keys
  module_indexes     = var.module_indexes
}

module "gitfolio_alb" {
  source               = "./module/LB"
  count                = local.shared ? 0 : 1

  vpc_id               = data.terraform_remote_state.shared.outputs.vpc_id
  public_subnet_ids    = module.gitfolio_network.public_subnet_ids
  any_ip               = var.any_ip
  frontend_id          = module.gitfolio_node[0].frontend_id
  backend_auth_id      = module.gitfolio_node[0].backend_auth_id
  ai_id                = module.gitfolio_node[0].ai_id

  route53_domain       = var.route53_domain
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
#   source           = "./module/ECR"
#   count            = local.shared ? 0 : 1
  
#   ecr_repo_name    = var.ecr_repo_name
#   tag_mutability   = var.tag_mutability
#   policy_tagStatus = var.policy_tagStatus
#   policy_countType = var.policy_countType
#   policy_countNum  = var.policy_countNum
# }