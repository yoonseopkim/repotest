resource "aws_instance" "master" {
  count         = var.on_master
  ami           = var.ami_id
  instance_type = var.instance_types["medium"]
  key_name      = var.ssh_keys["kubernetes"]
  subnet_id     = var.private_subnet_ids[var.instance_indexes["kubernetes"]]
  vpc_security_group_ids = [aws_security_group.master[0].id]
  private_ip = var.private_ips["master"]
  
  tags = {
    Name = "Gitfolio Kubernetes master node"
  }
}

resource "aws_security_group" "master" {
  count = var.on_master
  name = "master_sg"
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

  ingress {
    description = "Kubernetes API"
    from_port = 6443
    to_port = 6443
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
    Name = "Gitfolio Kubernetes master node security group"
  }
}