
###########################################
# Subnet
###########################################
# Public Subnet
resource "aws_subnet" "public_subnet" {
  for_each          = var.public_subnets
  vpc_id            = aws_vpc.main.id
  cidr_block        = each.value.cidr_block
  availability_zone = each.value.availability_zone



  tags = {
    Name = "${var.project_name}-public-subnet-${each.key}"
  }
}

# Private Subnet
resource "aws_subnet" "vpc_private_subnets" {
  for_each          = var.vpc_private_subnets
  vpc_id            = aws_vpc.main.id
  cidr_block        = each.value.cidr_block
  availability_zone = each.value.availability_zone

  tags = {
    Name = "${var.project_name}-private-subnet-${each.key}"
  }
}
