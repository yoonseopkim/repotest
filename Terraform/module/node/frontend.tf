resource "aws_instance" "frontend" {
  count                  = var.on_front
  ami                    = var.ami_id
  instance_type          = var.instance_types["low"]
  key_name               = var.ssh_keys["front"]
  subnet_id              = var.private_subnet_ids[var.instance_indexes["front"]]
  vpc_security_group_ids = [aws_security_group.front[0].id]
  private_ip             = var.private_ips["front"]
  iam_instance_profile   = "gitfolio_ec2_iam_profile"
  
  tags = {
    Name = "Gitfolio Frontend"
  }
}

resource "aws_security_group" "front" {
  count = var.on_front
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