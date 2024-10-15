data "aws_availability_zones" "selected" {
  state = "available"

  filter {
    name   = "zone-name"
    values = ["ap-northeast-2a", "ap-northeast-2c"]  # 원하는 특정 가용 영역 이름
  }
}

data "aws_eip" "nat" {
    tags = {
      Name = var.elastic_ip_names["nat"]
    }
}