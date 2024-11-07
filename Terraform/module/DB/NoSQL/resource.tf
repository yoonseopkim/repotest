resource "aws_instance" "nosql" {
  ami                    = var.ami_id
  instance_type          = var.instance_types["micro"]
  key_name               = var.ssh_keys["db"]
  subnet_id              = var.private_subnet_ids[var.instance_indexes["mongo"] + var.node_index]
  vpc_security_group_ids = [var.security_group_ids["nosql"]]
  private_ip             = var.private_ips["db${ var.node_index + 1 }"]
  iam_instance_profile   = var.iam_instance_profile

  root_block_device {
    volume_size = 20
  }
  
  tags = {
    Name = var.node_index == 0 ? "Gitfolio MongoDB" : "Gitfolio Redis",
    Environment = terraform.workspace,
    Service = "db",
    Type = var.node_index == 0 ? "mongo" : "redis"
  }
}

