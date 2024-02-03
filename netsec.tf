# For some reason - the default SG created by EKS only allows
# control-plane to control-plane NOT worker -> control-plane
# we need to figure out what SG it created and append a rule
# that allows traffic from workers to the control plane
# note that 'inbound' is set to 'self':
# https://docs.aws.amazon.com/eks/latest/userguide/sec-group-reqs.html

# Allow inbound traffic from the worker nodes to the EKS control plane
resource "aws_security_group_rule" "control_plane_to_worker" {
  type                     = "ingress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.eks_worker_sg.id
  security_group_id        = aws_eks_cluster.rancher_cluster.vpc_config[0].cluster_security_group_id
}

resource "aws_security_group" "eks_worker_sg" {
  name        = "eks-cluster-sg"
  description = "Security group for EKS cluster with HTTP/HTTPS access"
  vpc_id      = aws_vpc.cluster_lan.id

  # HTTP and HTTPS from anywhere 
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

  ingress {
    description = "Webhook"
    from_port   = 8443
    to_port     = 8443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # temp for troubleshooting
  ingress {
    description = "Kubelet"
    from_port   = 10250
    to_port     = 10250
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # SSH access to worker nodes
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
