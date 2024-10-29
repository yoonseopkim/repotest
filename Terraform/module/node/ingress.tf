resource "aws_instance" "ingress" {
  count         = var.on_ingress
  ami           = var.ami_id
  instance_type = var.instance_types["low"]
  key_name      = var.ssh_keys["kubernetes"]
  subnet_id     = var.private_subnet_ids[var.instance_indexes["kubernetes"]]
  vpc_security_group_ids = [aws_security_group.ingress[0].id]
  private_ip = var.private_ips["ingress"]
  
  tags = {
    Name = "Gitfolio Kubernetes ingress node"
  }
}

resource "aws_security_group" "ingress" {
  count = var.on_ingress
  name = "ingress_sg"
  vpc_id = var.vpc_id

  ingress {
    description = "ssh"
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = [var.any_ip]
  }

  ingress {
    description = "HTTP"
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = [var.any_ip]
  }

  ingress {
    description = "HTTPS"
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = [var.any_ip]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = [var.any_ip]
  }

  tags = {
    Name = "Gitfolio Kubernetes ingress node security group"
  }
}