resource "aws_instance" "mongo" {
  ami                    = var.ami_id
  instance_type          = var.instance_types["low"]
  key_name               = var.ssh_keys["mongo"]
  subnet_id              = var.private_subnet_ids[var.instance_indexes["mongo"]]
  vpc_security_group_ids = [aws_security_group.mongo.id]
  private_ip             = var.private_ips["mongo"]
  iam_instance_profile   = "gitfolio_ec2_iam_profile"

  root_block_device {
    volume_size = 20
  }
  
  tags = {
    Name = "Gitfolio MongoDB",
    Environment = terraform.workspace,
    Type = "mongo"
  }
}

resource "aws_security_group" "mongo" {
  name = "mongo_sg"
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
    description = "MongoDB"
    from_port = 27017
    to_port = 27017
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
    Name = "Gitfolio MongoDB security group"
  }
}