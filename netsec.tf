resource "aws_security_group" "eks_cluster_sg" {
  name        = "eks-cluster-sg"
  description = "Security group for EKS cluster with HTTP/HTTPS access"
  vpc_id      = aws_vpc.cluster_lan.id

  # HTTP and HTTPS from anywhere (as in your original SG)
  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # SSH for troubleshooting
  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "ICMP"
    from_port   = -1  # For ICMP, -1 indicates all types.
    to_port     = -1  # Similarly, -1 here indicates all codes.
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # EKS Control Plane communication (adjust CIDR and ports as necessary)
  ingress {
    description = "EKS Control Plane to Worker Nodes"
    from_port   = 10250
    to_port     = 10250
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/27", "10.0.0.32/27", "10.0.0.0/16"]
  }

  # Worker Node to Worker Node communication
  ingress {
    description = "Worker Node to Worker Node"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    self        = true
  }

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"  # Allow all outbound traffic
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "eks-cluster-sg"
  }
}

