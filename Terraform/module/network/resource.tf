locals {
  init   = terraform.workspace =="init"
  shared = terraform.workspace == "shared"
}

resource "aws_vpc" "gitfolio" {
  count                = local.shared ? 1 : 0
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  
  tags = {
    Name = "Gitfolio VPC"
  }
}

resource "aws_subnet" "public" {
  count             = local.init || local.shared ? 0 : length(var.public_subnet_cidrs)
  vpc_id            = var.vpc_id
  cidr_block        = var.public_subnet_cidrs[count.index]
  availability_zone = var.availability_zones[count.index % 2]
  map_public_ip_on_launch = true
  
  tags = {
    Name = "Gitfolio ${terraform.workspace} lb subnet${count.index + 1}"
  }
}

resource "aws_subnet" "nat" {
  count             = local.shared ? 1 : 0
  vpc_id            = aws_vpc.gitfolio[0].id
  cidr_block        = var.nat_subnet_cidr
  availability_zone = var.availability_zones[1]
  
  tags = {
    Name = "Gitfolio NAT subnet"
  }
}

resource "aws_subnet" "private" {
  count             = local.init || local.shared ? 0 : length(var.private_subnet_cidrs)
  vpc_id            = var.vpc_id
  cidr_block        = var.private_subnet_cidrs[count.index]
  availability_zone = var.availability_zones[count.index % 2]
  
  tags = {
    Name = "Gitfolio ${var.instance_names[count.index]} subnet"
  }
}

resource "aws_eip" "nat_eip" {
  count  = local.shared ? 1 : 0
  domain = "vpc"
  
  tags = {
    Name = "Gitfolio NAT EIP"
  }
}

resource "aws_internet_gateway" "igw" {
  count  = local.shared ? 1 : 0
  vpc_id = aws_vpc.gitfolio[0].id

  tags = {
    Name = "Gitfolio Internet Gateway"
  }
}

resource "aws_nat_gateway" "nat" {
  count         = local.shared ? 1 : 0
  allocation_id = aws_eip.nat_eip[0].id
  subnet_id     = aws_subnet.nat[0].id

  tags = {
    Name = "Gitfolio NAT Gateway"
  }

  depends_on = [ aws_eip.nat_eip, aws_internet_gateway.igw ]
}

resource "aws_route_table" "public" {
  count  = local.shared ? 1 : 0
  vpc_id = aws_vpc.gitfolio[0].id

  route {
    cidr_block = var.any_ip
    gateway_id = aws_internet_gateway.igw[0].id
  }

  tags = {
    Name = "Gitfolio public route table"
  }
}

resource "aws_route_table" "private" {
  count  = local.init || local.shared ? 0 : 1
  vpc_id = var.vpc_id

  route {
    cidr_block     = var.any_ip
    nat_gateway_id = var.nat_id
  }

  tags = {
    Name = "Gitfolio private route table"
  }
}

resource "aws_route_table_association" "public" {
  count          = local.init || local.shared ? 0 : length(aws_subnet.public)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = var.public_route_table_id
}

resource "aws_route_table_association" "nat" {
 count          = local.shared ? 1 : 0
 subnet_id      = aws_subnet.nat[0].id
 route_table_id = aws_route_table.public[0].id
}

resource "aws_route_table_association" "private" {
  count          = local.init || local.shared ? 0 : length(aws_subnet.private)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[0].id
}