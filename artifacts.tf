# create ssh keypair for local node access
resource "tls_private_key" "private_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "local_file" "private_key" {
  content         = tls_private_key.private_key.private_key_pem
  filename        = "${path.module}/out/aws_private_key.pem"
  file_permission = "0600"
}
resource "aws_key_pair" "generated_key" {
  key_name   = "worker_key"
  public_key = tls_private_key.private_key.public_key_openssh
}

# create Kubeconfig file based on below template
data "aws_eks_cluster" "rancher_data" {
  name = aws_eks_cluster.rancher_cluster.name
}

data "aws_eks_cluster_auth" "rancher_auth" {
  name = aws_eks_cluster.rancher_cluster.name
}

locals {
  kubeconfig = <<KUBECONFIG
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
      apiVersion: client.authentication.k8s.io/v1beta1
      command: aws
      args:
        - "eks"
        - "get-token"
        - "--cluster-name"
        - "${data.aws_eks_cluster.rancher_data.name}"
KUBECONFIG
}

# Create the eksRancher.yaml file
resource "local_file" "eks_rancher_config" {
  filename = "${path.module}/out/eksRancher.yaml"
  content  = local.kubeconfig
}
