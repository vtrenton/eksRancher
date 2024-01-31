resource "aws_vpc" "cluster_lan" {
  cidr_block           = "10.0.0.0/16"
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
  # vpc + 11 net bits == netsize of 10.0.0.0 to 10.0.0.31 (10.0.0.0/27)
  cidr_block        = cidrsubnet(aws_vpc.cluster_lan.cidr_block, 11, 0)
  vpc_id            = aws_vpc.cluster_lan.id
  availability_zone = "us-east-1a"
  map_public_ip_on_launch = true
  tags = {
    Name = "rancher_lan_a"
  }
}

resource "aws_subnet" "rancher_master_b" {
  # vpc + 11 net bits == netsize of 10.0.0.32 to 10.0.0.63 (10.0.0.0/27)
  cidr_block        = cidrsubnet(aws_vpc.cluster_lan.cidr_block, 11, 1)
  vpc_id            = aws_vpc.cluster_lan.id
  availability_zone = "us-east-1b"
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
