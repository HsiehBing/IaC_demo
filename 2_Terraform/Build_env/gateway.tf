
############################################
# Internet Gateway
############################################
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "${var.project_name}-internet-gateway"
  }
}

