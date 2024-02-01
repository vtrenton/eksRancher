resource "aws_vpc" "cluster_lan" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    name = "cluster_lan"
  }
}

resource "aws_internet_gateway" "rancher_cluster_gw" {
  vpc_id = aws_vpc.cluster_lan.id

  tags = {
    name = "cluster_internet_gateway"
  }
}

# Create a new route table for the VPC
resource "aws_route_table" "cluster_route_table" {
  vpc_id = aws_vpc.cluster_lan.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.rancher_cluster_gw.id
  }

  tags = {
    Name = "cluster_route_table"
  }
}

resource "aws_subnet" "rancher_master_a" {
  # vpc + 8 net bits = netsize of 10.0.0.0/24
  cidr_block        = cidrsubnet(aws_vpc.cluster_lan.cidr_block, var.az_subnet, 0)
  vpc_id            = aws_vpc.cluster_lan.id
  availability_zone = var.az_a
  map_public_ip_on_launch = true
  tags = {
    Name = "rancher_lan_a"
  }
}

resource "aws_subnet" "rancher_master_b" {
  # vpc + 8 net bits == netsize of 10.0.1.0/24
  cidr_block        = cidrsubnet(aws_vpc.cluster_lan.cidr_block, var.az_subnet, 1)
  vpc_id            = aws_vpc.cluster_lan.id
  availability_zone = var.az_b
  map_public_ip_on_launch = true
  tags = {
    Name = "rancher_lan_b"
  }
}

# Associate the route table with the subnets
resource "aws_route_table_association" "a_association" {
  subnet_id      = aws_subnet.rancher_master_a.id
  route_table_id = aws_route_table.cluster_route_table.id
}

resource "aws_route_table_association" "b_association" {
  subnet_id      = aws_subnet.rancher_master_b.id
  route_table_id = aws_route_table.cluster_route_table.id
}
