terraform {
    required_providers {
        aws = {
            source = "hashicorp/aws"
        }
    }
}

provider "aws" {
    region = "us-east-1"
}

# Key for secrets encryption
resource "aws_kms_key" "rancher_secrets" {
    description = "KMS key for Rancher Secret Encryption"
}

# Create EKS Cluster for Rancher to live on
resource "aws_eks_cluster" "rancher_cluster" {
    name     = "RancherMC"
    version  = "1.27"
    role_arn = aws_iam_role.eks_cluster_role.arn
    vpc_config {
        subnet_ids = [
            aws_subnet.rancher_master_a.id,
            aws_subnet.rancher_master_b.id
        ]

        endpoint_private_access = true
        endpoint_public_access  = true
    }

    encryption_config {
        provider {
            key_arn = aws_kms_key.rancher_secrets.arn
        }
        resources = ["secrets"]
    }
}

# For some reason - the default SG created by EKS only allows
# control-plane to control-plane NOT worker -> control-plane
# we need to figure out what SG it created and append a rule
# that allows traffic from workers to the control plane
# note that 'inbound' is set to 'self':
# https://docs.aws.amazon.com/eks/latest/userguide/sec-group-reqs.html
data "aws_eks_cluster" "eks_cluster_data" {
  name = "RancherMC"
}

# create ssh keypair for local node access
resource "tls_private_key" "private_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "local_file" "private_key" {
  content         = tls_private_key.private_key.private_key_pem
  filename        = "aws_private_key.pem"
  file_permission = "0600"
}
resource "aws_key_pair" "generated_key" {
  key_name   = "worker_key"
  public_key = tls_private_key.private_key.public_key_openssh
}

# launch config for workers
resource "aws_launch_template" "rancher_workers" {
    name_prefix   = "rancher-cow-"
    #image_id      = "ami-02f32259ae4f4512f"
    instance_type = "t3.medium"
    
    # ssh key name
    key_name      = aws_key_pair.generated_key.key_name    

    vpc_security_group_ids = [aws_security_group.eks_worker_sg.id]
    
    lifecycle {
        create_before_destroy = true
    }
}

# Create a node group for the workers
resource "aws_eks_node_group" "rancher_node_group" {
  cluster_name    = aws_eks_cluster.rancher_cluster.name
  node_group_name = "rancher-node-group"
  node_role_arn   = aws_iam_role.eks_worker_role.arn
  subnet_ids      = [
    aws_subnet.rancher_master_a.id,
    aws_subnet.rancher_master_b.id
  ]

  scaling_config {
    desired_size = 3
    max_size     = 4
    min_size     = 1
  }

  # Specify the launch template and version
  launch_template {
    id      = aws_launch_template.rancher_workers.id
    version = "$Latest"
  }

  depends_on = [
    aws_eks_cluster.rancher_cluster
  ]
}

# Install ingress-nginx on the cluster

# Install Cert-manager on the cluster

# Install Rancher on the cluster

# Output cluster kubeconfig
data "aws_eks_cluster" "rancher_data" {
  name = aws_eks_cluster.rancher_cluster.name
}

data "aws_eks_cluster_auth" "rancher_auth" {
  name = aws_eks_cluster.rancher_cluster.name
}

output "kubeconfig" {
  value = <<KUBECONFIG
apiVersion: v1
clusters:
- cluster:
    server: ${data.aws_eks_cluster.rancher_data.endpoint}
    certificate-authority-data: ${data.aws_eks_cluster.rancher_data.certificate_authority[0].data}
  name: ${data.aws_eks_cluster.rancher_data.name}
contexts:
- context:
    cluster: ${data.aws_eks_cluster.rancher_data.name}
    user: ${data.aws_eks_cluster.rancher_data.name}
  name: ${data.aws_eks_cluster.rancher_data.name}
current-context: ${data.aws_eks_cluster.rancher_data.name}
kind: Config
preferences: {}
users:
- name: ${data.aws_eks_cluster.rancher_data.name}
  user:
    exec:
      apiVersion: client.authentication.k8s.io/v1alpha1
      command: aws
      args:
        - "eks"
        - "get-token"
        - "--cluster-name"
        - "${data.aws_eks_cluster.rancher_data.name}"
KUBECONFIG
}
