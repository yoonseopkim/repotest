resource "aws_instance" "db" {
  count                  = 4
  ami                    = var.ami_id
  instance_type          = var.instance_types["micro"]
  key_name               = var.ssh_keys["db"]
  subnet_id              = var.private_subnet_ids[var.instance_indexes["db"]]
  vpc_security_group_ids = [aws_security_group.all.id]
  private_ip             = var.private_ips["db_${ var.module_indexes[count.index] }"]
  iam_instance_profile   = "gitfolio_ec2_iam_profile"

  root_block_device {
    volume_size = 20
  }
  
  tags = {
    Name = "Gitfolio DB ${ var.module_indexes[count.index] }",
    Environment = terraform.workspace,
    Service = "db"
    # Module = var.module_indexes[count.index]
  }
}

# resource "aws_security_group" "my-mongo" {
#   name = "my_mongo_sg"
#   vpc_id = var.vpc_id

#   ingress {
#     description = "ssh"
#     from_port = 22
#     to_port = 22
#     protocol = "tcp"
#     cidr_blocks = [var.any_ip]
#   }

#   ingress {
#     description = "HTTP"
#     from_port = 80
#     to_port = 80
#     protocol = "tcp"
#     cidr_blocks = [var.any_ip]
#   }

#   ingress {
#     description = "HTTPS"
#     from_port = 443
#     to_port = 443
#     protocol = "tcp"
#     cidr_blocks = [var.any_ip]
#   }

#   ingress {
#     description = "MySQL"
#     from_port = 3306
#     to_port = 3306
#     protocol = "tcp"
#     cidr_blocks = [var.any_ip]
#   }

#   ingress {
#     description = "MongoDB"
#     from_port = 27017
#     to_port = 27017
#     protocol = "tcp"
#     cidr_blocks = [var.any_ip]
#   }

#   egress {
#     from_port = 0
#     to_port = 0
#     protocol = "-1"
#     cidr_blocks = [var.any_ip]
#   }

#   tags = {
#     Name = "Gitfolio MySQL_MongoDB security group"
#   }
# }

resource "aws_security_group" "all" {
  name = "all_sg"
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
    description = "MySQL"
    from_port = 3306
    to_port = 3306
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
    Name = "Gitfolio all DB security group"
  }
}

# resource "aws_security_group" "mysql" {
#   name = "mysql_sg"
#   vpc_id = var.vpc_id

#   ingress {
#     description = "ssh"
#     from_port = 22
#     to_port = 22
#     protocol = "tcp"
#     cidr_blocks = [var.any_ip]
#   }

#   ingress {
#     description = "HTTP"
#     from_port = 80
#     to_port = 80
#     protocol = "tcp"
#     cidr_blocks = [var.any_ip]
#   }

#   ingress {
#     description = "HTTPS"
#     from_port = 443
#     to_port = 443
#     protocol = "tcp"
#     cidr_blocks = [var.any_ip]
#   }

#   ingress {
#     description = "MySQL"
#     from_port = 3306
#     to_port = 3306
#     protocol = "tcp"
#     cidr_blocks = [var.any_ip]
#   }

#   egress {
#     from_port = 0
#     to_port = 0
#     protocol = "-1"
#     cidr_blocks = [var.any_ip]
#   }

#   tags = {
#     Name = "Gitfolio MySQL security group"
#   }
# }

# resource "aws_security_group" "mongo" {
#   name = "mongo_sg"
#   vpc_id = var.vpc_id

#   ingress {
#     description = "ssh"
#     from_port = 22
#     to_port = 22
#     protocol = "tcp"
#     cidr_blocks = [var.any_ip]
#   }

#   ingress {
#     description = "HTTP"
#     from_port = 80
#     to_port = 80
#     protocol = "tcp"
#     cidr_blocks = [var.any_ip]
#   }

#   ingress {
#     description = "MongoDB"
#     from_port = 27017
#     to_port = 27017
#     protocol = "tcp"
#     cidr_blocks = [var.any_ip]
#   }

#   egress {
#     from_port = 0
#     to_port = 0
#     protocol = "-1"
#     cidr_blocks = [var.any_ip]
#   }

#   tags = {
#     Name = "Gitfolio MongoDB security group"
#   }
# }

# resource "aws_security_group" "redis" {
#   name = "redis_sg"
#   vpc_id = var.vpc_id

#   ingress {
#     description = "ssh"
#     from_port = 22
#     to_port = 22
#     protocol = "tcp"
#     cidr_blocks = [var.any_ip]
#   }

#   ingress {
#     description = "HTTP"
#     from_port = 80
#     to_port = 80
#     protocol = "tcp"
#     cidr_blocks = [var.any_ip]
#   }

#   ingress {
#     description = "HTTPS"
#     from_port = 443
#     to_port = 443
#     protocol = "tcp"
#     cidr_blocks = [var.any_ip]
#   }

#   ingress {
#     description = "Redis"
#     from_port = 6379
#     to_port = 6379
#     protocol = "tcp"
#     cidr_blocks = [var.any_ip]
#   }

#   egress {
#     from_port = 0
#     to_port = 0
#     protocol = "-1"
#     cidr_blocks = [var.any_ip]
#   }

#   tags = {
#     Name = "Gitfolio redis security group"
#   }
# }