#== vpc ==
resource "aws_vpc" "vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = merge(
    var.vpc_default_tags,
    {
      Name = var.project
    }
  )
}

#== Internet Gateway ==
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = merge(
    var.vpc_default_tags,
    {
      Name = "${var.project}-igw"
    }
  )
}

#== Public Subnets ==
resource "aws_subnet" "public" {
  count = length(var.public_subnet_cidrs)

  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.public_subnet_cidrs[count.index]
  availability_zone       = element(var.availability_zones, count.index)
  map_public_ip_on_launch = true

  tags = merge(
    var.vpc_default_tags,
    {
      Name                     = "${var.project}-public-general-${element(var.availability_zones, count.index)}"
      "kubernetes.io/role/elb" = "1"
    }
  )
}


#== Shared Private Subnets ==
resource "aws_subnet" "shared_private" {
  count = length(var.shared_private_subnet_cidrs)

  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.shared_private_subnet_cidrs[count.index]
  availability_zone = element(var.availability_zones, count.index)

  tags = merge(
    var.vpc_default_tags,
    {
      Name                              = "${var.project}-private-shared-${element(var.availability_zones, count.index)}"
      "kubernetes.io/role/internal-elb" = "1"
    }
  )
}

#== EKS Control Plane Subnets ==
resource "aws_subnet" "eks_control_plane" {
  count = length(var.eks_control_plane_subnet_cidrs)

  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.eks_control_plane_subnet_cidrs[count.index]
  availability_zone = element(var.availability_zones, count.index)

  tags = merge(
    var.vpc_default_tags,
    {
      Name = "${var.project}-private-eks-control-${element(var.availability_zones, count.index)}"
    }
  )
}

#== EKS Worker Node Subnets ==
resource "aws_subnet" "eks_worker_node" {
  count = length(var.eks_worker_node_subnet_cidrs)

  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.eks_worker_node_subnet_cidrs[count.index]
  availability_zone = element(var.availability_zones, count.index)

  tags = merge(
    var.vpc_default_tags,
    {
      Name = "${var.project}-private-eks-worker-${element(var.availability_zones, count.index)}"
    }
  )
}

#== Elastic IP for NAT Gateway ==
resource "aws_eip" "nat" {
  count = var.single_nat_gateway ? 1 : length(var.availability_zones)

  domain = "vpc"

  tags = merge(
    var.vpc_default_tags,
    {
      Name = "${var.project}-nat-eip-${count.index + 1}"
    }
  )

  depends_on = [aws_internet_gateway.igw]
}

#== NAT Gateway ==
resource "aws_nat_gateway" "this" {
  count = var.single_nat_gateway ? 1 : length(var.availability_zones)

  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = aws_subnet.public[count.index].id

  tags = merge(
    var.vpc_default_tags,
    {
      Name = "${var.project}-nat-gateway-${count.index + 1}"
    }
  )

  depends_on = [aws_internet_gateway.igw]
}

#== Route Tables ==
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.vpc.id

  tags = merge(
    var.vpc_default_tags,
    {
      Name = "${var.project}-public-rtb"
    }
  )
}

resource "aws_route" "public_internet_gateway" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

#== Private Route Tables ==
# Shared Private Route Tables
resource "aws_route_table" "shared_private" {
  count = var.single_nat_gateway ? 1 : length(var.availability_zones)

  vpc_id = aws_vpc.vpc.id

  tags = merge(
    var.vpc_default_tags,
    {
      Name = "${var.project}-private-shared-rtb-${count.index + 1}"
    }
  )
}

resource "aws_route" "shared_private_nat_gateway" {
  count = var.single_nat_gateway ? 1 : length(var.availability_zones)

  route_table_id         = aws_route_table.shared_private[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.this[count.index].id
}

#== EKS Control Plane Private Route Tables ==
resource "aws_route_table" "eks_private_control_plane" {
  count = var.single_nat_gateway ? 1 : length(var.availability_zones)

  vpc_id = aws_vpc.vpc.id

  tags = merge(
    var.vpc_default_tags,
    {
      Name = "${var.project}-private-eks-control-plane-rtb-${count.index + 1}"
    }
  )
}

resource "aws_route" "eks_private_control_plane_nat_gateway" {
  count = var.single_nat_gateway ? 1 : length(var.availability_zones)

  route_table_id         = aws_route_table.eks_private_control_plane[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.this[count.index].id
}

#== EKS Work Node Private Route Tables ==
resource "aws_route_table" "eks_private_work_node" {
  count = var.single_nat_gateway ? 1 : length(var.availability_zones)

  vpc_id = aws_vpc.vpc.id

  tags = merge(
    var.vpc_default_tags,
    {
      Name = "${var.project}-private-eks-rtb-${count.index + 1}"
    }
  )
}

resource "aws_route" "eks_private_work_node_nat_gateway" {
  count = var.single_nat_gateway ? 1 : length(var.availability_zones)

  route_table_id         = aws_route_table.eks_private_work_node[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.this[count.index].id
}


#== Route Table Associations ==
resource "aws_route_table_association" "public" {
  count = length(var.public_subnet_cidrs)

  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "shared_private" {
  count = length(var.shared_private_subnet_cidrs)

  subnet_id      = aws_subnet.shared_private[count.index].id
  route_table_id = var.single_nat_gateway ? aws_route_table.shared_private[0].id : aws_route_table.shared_private[count.index % length(var.availability_zones)].id
}

resource "aws_route_table_association" "eks_control_plane" {
  count = length(var.eks_control_plane_subnet_cidrs)

  subnet_id      = aws_subnet.eks_control_plane[count.index].id
  route_table_id = var.single_nat_gateway ? aws_route_table.eks_private_control_plane[0].id : aws_route_table.eks_private_control_plane[count.index % length(var.availability_zones)].id
}

resource "aws_route_table_association" "eks_worker_node" {
  count = length(var.eks_worker_node_subnet_cidrs)

  subnet_id      = aws_subnet.eks_worker_node[count.index].id
  route_table_id = var.single_nat_gateway ? aws_route_table.eks_private_work_node[0].id : aws_route_table.eks_private_work_node[count.index % length(var.availability_zones)].id
}
