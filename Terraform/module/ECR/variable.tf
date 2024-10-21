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