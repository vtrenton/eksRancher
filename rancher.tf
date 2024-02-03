provider "helm" {
    kubernetes {
        config_path = local_file.eks_rancher_config.filename
    }
    debug = true
}

# Install ingress-nginx on the cluster
resource "helm_release" "ingress_nginx" {
  name             = "ingress-nginx"
  namespace        = "ingress-nginx"
  create_namespace = true
  repository       = "https://kubernetes.github.io/ingress-nginx"
  chart            = "ingress-nginx"

  # expose via elb
  set {
    name  = "service.type"
    value = "LoadBalancer"
  }

  # Set as default ingressClass
  set {
    name  = "controller.ingressClassResource.default"
    value = true
  }

  depends_on = [
    aws_eks_node_group.rancher_node_group
  ]
}

# Install Cert-manager on the cluster
resource "helm_release" "cert_manager" {
  name             = "cert-manager"
  namespace        = "cert-manager"
  create_namespace = true
  repository       = "https://charts.jetstack.io"
  chart            = "cert-manager"

  set {
    name   = "installCRDs"
    value  = true
  }

  depends_on = [
    aws_eks_node_group.rancher_node_group
  ]
}

# Install Rancher on the cluster
resource "helm_release" "rancher" {
  name             = "rancher"
  namespace        = "cattle-system"
  create_namespace = true
  repository       = "https://releases.rancher.com/server-charts/stable"
  chart            = "rancher"

  set {
    name  = "hostname"
    value = var.rancher_hostname
  }
  set {
    name  = "bootstrapPassword"
    value = var.bootstrapPassword
  }
  set {
    name  = "ingress.tls.source"
    value = "letsEncrypt"
  }
  set {
    name  = "letsEncrypt.email"
    value = var.letsEncryptEmail
  }
  set {
    name  = "letsEncrypt.ingress.class"
    value = "nginx"
  }

  depends_on = [
    aws_eks_node_group.rancher_node_group,
    helm_release.ingress_nginx,
    helm_release.cert_manager
  ]
}
