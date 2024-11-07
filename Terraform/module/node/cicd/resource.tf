resource "aws_instance" "jenkins" {
  ami           = var.ami_id
  instance_type = var.instance_types["high"]
  key_name      = var.ssh_keys["jenkins"]
  subnet_id     = var.private_subnet_ids[var.instance_indexes["jenkins"]]
  vpc_security_group_ids = [var.security_group_ids["cicd"]]
  private_ip = var.private_ips["jenkins"]
  
  tags = {
    Name = "Gitfolio Jenkins"
  }
}

resource "aws_instance" "argo" {
  ami           = var.ami_id
  instance_type = var.instance_types["high"]
  key_name      = var.ssh_keys["argo"]
  subnet_id     = var.private_subnet_ids[var.instance_indexes["argo"]]
  vpc_security_group_ids = [var.security_group_ids["cicd"]]
  private_ip = var.private_ips["argo"]
  
  tags = {
    Name = "Gitfolio ArgoCD"
  }
}
