resource "aws_instance" "master" {
  ami           = var.ami_id
  instance_type = var.instance_types["medium"]
  subnet_id     = var.private_subnet_ids[var.instance_indexes["kubernetes"]]
  vpc_security_group_ids = [var.security_group_ids["base"], var.security_group_ids["kubernetes"]]
  private_ip = var.private_ips["master"]
  
  tags = {
    Name = "Gitfolio Kubernetes master node"
    Environment = terraform.workspace
    Service = "master"        # aws_ec2.yaml에서 이 태그로 그룹핑
    Type = "kubernetes"
  }
}

resource "aws_instance" "ingress" {
  ami           = var.ami_id
  instance_type = var.instance_types["low"]
  subnet_id     = var.private_subnet_ids[var.instance_indexes["kubernetes"]]
  vpc_security_group_ids = [var.security_group_ids["kubernetes"]]
  private_ip = var.private_ips["ingress"]
  
  tags = {
    Name = "Gitfolio Kubernetes ingress node"
    Environment = terraform.workspace
    Service = "worker"        # aws_ec2.yaml에서 이 태그로 그룹핑
    Type = "kubernetes"
  }
}
