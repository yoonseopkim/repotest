resource "aws_security_group" "redis" {
  vpc_id = var.vpc_id

  ingress {
    description = "ssh"
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = [var.any_ip]
  }

  ingress {
    description = "Redis"
    from_port = 6379
    to_port = 6379
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
    Name = "Gitfolio Redis security group"
  }
}

resource "aws_instance" "redis" {
  ami                    = var.ami_id
  instance_type          = var.instance_types["low"]
  key_name               = var.ssh_keys["redis"]
  subnet_id              = var.private_subnet_ids[var.instance_indexes["redis"]]
  vpc_security_group_ids = [aws_security_group.redis.id]
  private_ip             = var.private_ips["redis"]
  
  root_block_device {
    volume_size = 20
  }
  
  tags = {
    Name = "Gitfolio Redis"
  }
}