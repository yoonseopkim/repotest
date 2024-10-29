resource "aws_subnet" "db" {
  count             = length(var.db_subnet_cidrs)
  vpc_id            = var.vpc_id
  cidr_block        = var.db_subnet_cidrs[count.index]
  availability_zone = var.availability_zones[count.index]
  
  tags = {
    Name = "Gitfolio RDS subnet ${var.availability_zones[count.index]}"
  }
}

resource "aws_db_subnet_group" "mysql" {
    subnet_ids = aws_subnet.db[*].id

    tags = {
        Name = "Gitfolio RDS subnet group"
    }
}

resource "aws_security_group" "mysql" {
  name = "mysql_sg"
  vpc_id = var.vpc_id

  ingress {
    description = "MySQL"
    from_port = 3306
    to_port = 3306
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
    Name = "Gitfolio MySQL security group"
  }
}

resource "aws_db_instance" "mysql" {
    identifier             = var.identifier
    engine                 = var.engine
    engine_version         = var.engine_version
    instance_class         = var.instance_class
    allocated_storage      = var.allocated_storage
    storage_type           = var.storage_type

    db_name                = var.db_name
    username               = var.db_username
    password               = var.db_password
    
    publicly_accessible    = false
    skip_final_snapshot    = true
    vpc_security_group_ids = [aws_security_group.mysql.id]
    db_subnet_group_name   = aws_db_subnet_group.mysql.name

    tags = {
        Name = "${var.identifier}"
    }
}