# resource "aws_security_group" "argo" {
#   name = "argo_sg"
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

#   egress {
#     from_port = 0
#     to_port = 0
#     protocol = "-1"
#     cidr_blocks = [var.any_ip]
#   }

#   tags = {
#     Name = "Gitfolio ArgoCD security group"
#   }
# }

# resource "aws_instance" "argo" {
#   ami           = var.ami_id
#   instance_type = var.instance_types["high"]
#   key_name      = var.ssh_keys["argo"]
#   subnet_id     = var.private_subnet_ids[var.instance_indexes["argo"]]
#   vpc_security_group_ids = [aws_security_group.argo.id]
#   private_ip = var.private_ips["argo"]
  
#   tags = {
#     Name = "Gitfolio ArgoCD"
#   }
# }