resource "aws_security_group" "front" {
  name = "front_sg"
  vpc_id = var.vpc_id

  ingress {
    description = "ssh"
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = [var.any_ip]
  }

  ingress {
    description = "NextJS"
    from_port = 3000
    to_port = 3000
    protocol = "tcp"
    cidr_blocks = [var.public_subnet_cidrs[0], var.public_subnet_cidrs[1]]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = [var.any_ip]
  }

  tags = {
    Name = "Gitfolio frontend security group"
  }
}

resource "aws_instance" "frontend" {
  ami           = var.ami_id
  instance_type = var.instance_types["low"]
  key_name      = var.ssh_keys["front"]
  subnet_id     = var.private_subnet_ids[var.instance_indexes["front"]]
  vpc_security_group_ids = [aws_security_group.front.id]
  private_ip = var.private_ips["front"]
  
  tags = {
    Name = "Gitfolio Frontend"
  }
}