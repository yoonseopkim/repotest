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
  
  tags = {
    Name = count.index == 0 ? "Dev Load Balancer subnet" : "Dev NAT subnet"
  }
}

resource "aws_subnet" "private" {
  count             = length(var.private_subnet_cidrs)
  vpc_id            = aws_vpc.gitfolio.id
  cidr_block        = var.private_subnet_cidrs[count.index]
  availability_zone = data.aws_availability_zones.selected.names[count.index % 2]
  
  tags = {
    Name = "Dev ${var.instance_names[count.index]} subnet"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.gitfolio.id

  tags = {
    Name = "Dev Internet Gateway"
  }
}

resource "aws_nat_gateway" "nat" {
  allocation_id = data.aws_eip.nat.id
  subnet_id = aws_subnet.public[1].id

  tags = {
    Name = "Dev NAT Gateway"
  }

  depends_on = [ aws_internet_gateway.igw ]
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