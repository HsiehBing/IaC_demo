############################################
# Public Route Table
############################################
# public

resource "aws_route_table" "route_public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0" # 使用 0.0.0.0/0 代表所有外部流量
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "${var.project_name}-public-route-table"
  }
}
