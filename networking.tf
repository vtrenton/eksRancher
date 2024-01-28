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

resource "aws_subnet" "rancher_master_a" {
  # vpc + 11 net bits == netsize of 10.0.0.0 to 10.0.0.31 (10.0.0.0/27)
  cidr_block        = cidrsubnet(aws_vpc.cluster_lan.cidr_block, 11, 0)
  vpc_id            = aws_vpc.cluster_lan.id
  availability_zone = "us-east-1a"
  tags = {
    Name = "rancher_lan_b"
  }
}

resource "aws_subnet" "rancher_master_b" {
  # vpc + 11 net bits == netsize of 10.0.0.32 to 10.0.0.63 (10.0.0.0/27)
  cidr_block        = cidrsubnet(aws_vpc.cluster_lan.cidr_block, 11, 32)
  vpc_id            = aws_vpc.cluster_lan.id
  availability_zone = "us-east-1b"
  tags = {
    Name = "rancher_lan_b"
  }
}
