resource "aws_vpc" "gitfolio" {
  cidr_block = var.vpc_cidr
  enable_dns_hostnames = true
  
  tags = {
    Name = "Gitfolio VPC"
  }
}

resource "aws_subnet" "public" {
  count             = length(var.public_subnet_cidrs)
  vpc_id            = aws_vpc.gitfolio.id
  cidr_block        = var.public_subnet_cidrs[count.index]
  availability_zone = data.aws_availability_zones.selected.names[0]
  map_public_ip_on_launch = true
  
  tags = {
    Name = count.index == 0 ? "Gitfolio Load Balancer subnet" : "Gitfolio NAT subnet"
  }
}

resource "aws_subnet" "private" {
  count             = length(var.private_subnet_cidrs)
  vpc_id            = aws_vpc.gitfolio.id
  cidr_block        = var.private_subnet_cidrs[count.index]
  availability_zone = data.aws_availability_zones.selected.names[count.index % 2]
  
  tags = {
    Name = "Gitfolio ${var.instance_names[count.index]} subnet"
  }
}

resource "aws_eip" "nat_eip" {
  domain = "vpc"
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.gitfolio.id

  tags = {
    Name = "Gitfolio Internet Gateway"
  }
}

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id = aws_subnet.public[1].id

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
    cidr_block = var.any_ip
    nat_gateway_id = aws_nat_gateway.nat.id
  }

  tags = {
    Name = "Gitfolio private route table"
  }

  depends_on = [ aws_nat_gateway.nat ]
}

resource "aws_route_table_association" "public" {
  count = length(aws_subnet.public)
  subnet_id = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private" {
  count = length(aws_subnet.private)
  subnet_id = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}