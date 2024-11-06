resource "aws_instance" "jenkins" {
  count         = var.on_jenkins
  ami           = var.ami_id
  instance_type = var.instance_types["high"]
  key_name      = var.ssh_keys["jenkins"]
  subnet_id     = var.private_subnet_ids[var.instance_indexes["jenkins"]]
  vpc_security_group_ids = [aws_security_group.jenkins[0].id]
  private_ip = var.private_ips["jenkins"]
  
  tags = {
    Name = "Gitfolio Jenkins"
  }
}

resource "aws_security_group" "jenkins" {
  count = var.on_jenkins == 0 ? 0 : 1
  name = "jenkins_sg"
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
    description = "Gitfolio API"
    from_port = 5000
    to_port = 5000
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
    Name = "Gitfolio Jenkins security group"
  }
}