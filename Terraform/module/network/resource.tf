locals {
  shared = terraform.workspace == "shared"
}

resource "aws_vpc" "gitfolio" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  
  tags = {
    Name = "Gitfolio VPC"
  }
}

resource "aws_subnet" "public" {
  count             = length(var.public_subnet_cidrs)
  vpc_id            = aws_vpc.gitfolio.id
  cidr_block        = var.public_subnet_cidrs[count.index]
  availability_zone = var.availability_zones[count.index % 2]
  map_public_ip_on_launch = true
  
  tags = {
    Name = "Gitfolio ${ terraform.workspace } lb subnet${ count.index + 1 }"
  }
}

resource "aws_subnet" "nat" {
  vpc_id            = aws_vpc.gitfolio.id
  cidr_block        = var.nat_subnet_cidr
  availability_zone = var.availability_zones[1]
  
  tags = {
    Name = "Gitfolio NAT subnet"
  }
}

resource "aws_subnet" "private" {
  count             = length(var.private_subnet_cidrs)
  vpc_id            = aws_vpc.gitfolio.id
  cidr_block        = var.private_subnet_cidrs[count.index]
  availability_zone = var.availability_zones[count.index % 2]
  
  tags = {
    Name = "Gitfolio ${var.instance_names[count.index]} subnet"
  }
}

resource "aws_subnet" "rds" {
  count             = length(var.db_subnet_cidrs)
  vpc_id            = aws_vpc.gitfolio.id
  cidr_block        = var.db_subnet_cidrs[count.index]
  availability_zone = var.availability_zones[count.index]
  
  tags = {
    Name = "Gitfolio RDS subnet${count.index}"
  }
}

resource "aws_db_subnet_group" "rds" {
  subnet_ids = aws_subnet.rds[*].id

  tags = {
    Name = "Gitfolio RDS subnet group"
  }
}

resource "aws_eip" "nat_eip" {
  domain = "vpc"
  
  tags = {
    Name = "Gitfolio NAT EIP"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.gitfolio.id

  tags = {
    Name = "Gitfolio Internet Gateway"
  }
}

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.nat.id

  tags = {
    Name = "Gitfolio NAT Gateway"
  }

  depends_on = [ aws_eip.nat_eip, aws_internet_gateway.igw ]
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.gitfolio.id

  route {
    cidr_block = var.any_ip
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "Gitfolio public route table"
  }
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.gitfolio.id

  route {
    cidr_block     = var.any_ip
    nat_gateway_id = aws_nat_gateway.nat.id
  }

  tags = {
    Name = "Gitfolio private route table"
  }
}

resource "aws_route_table_association" "public" {
  count          = length(aws_subnet.public)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "nat" {
 subnet_id      = aws_subnet.nat.id
 route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private" {
  count          = length(aws_subnet.private)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "rds" {
  count          = length(aws_subnet.rds)
  subnet_id      = aws_subnet.rds[count.index].id
  route_table_id = aws_route_table.private.id
}

resource "aws_security_group" "web" {
  name = "web_sg"
  vpc_id = aws_vpc.gitfolio.id

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

  ingress {
    description = "Backend"
    from_port = 8080
    to_port = 8081
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
    Name = "Gitfolio web security group"
  }
}

resource "aws_security_group" "cicd" {
  name = "cicd_sg"
  vpc_id = aws_vpc.gitfolio.id

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
    Name = "Gitfolio CI/CD security group"
  }
}

resource "aws_security_group" "kubernetes" {
  name = "kubernetes_sg"
  vpc_id = aws_vpc.gitfolio.id

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
    Name = "Gitfolio kubernetes master node security group"
  }
}

resource "aws_security_group" "rds" {
  name = "rds_sg"
  vpc_id = aws_vpc.gitfolio.id

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

resource "aws_security_group" "nosql" {
  name = "nosql_sg"
  vpc_id = aws_vpc.gitfolio.id

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
    Name = "Gitfolio NoSQL security group"
  }
}
