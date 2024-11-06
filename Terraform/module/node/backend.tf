resource "aws_instance" "backend" {
  count         = var.on_back
  ami           = var.ami_id
  instance_type = var.instance_types["micro"]
  key_name      = var.ssh_keys["back"]
  subnet_id     = var.private_subnet_ids[var.instance_indexes["back"]]
  vpc_security_group_ids = [aws_security_group.back[0].id]
  private_ip = var.private_ips["back_${ var.module_indexes[count.index] }"]
  iam_instance_profile   = "gitfolio_ec2_iam_profile"
  
  tags = {
    Name = "Gitfolio BE ${ var.module_indexes[count.index] }",
    Environment = terraform.workspace
    Service = "back"
    Module = var.module_indexes[count.index]
  }
}

resource "aws_security_group" "back" {
  count = var.on_back == 0 ? 0 : 1
  name = "back_sg"
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
    description = "Gitfolio API"
    from_port = 5000
    to_port = 5000
    protocol = "tcp"
    cidr_blocks = [var.any_ip]
  }

  ingress {
    description = "Spring"
    from_port = 8080
    to_port = 8080
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
    Name = "Gitfolio backend security group"
  }
}