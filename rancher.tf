provider "helm" {
    kubernetes {
        config_path = local_file.eks_rancher_config.filename
    }
}

# Install ingress-nginx on the cluster
resource "helm_release" "ingress_nginx" {
  name             = "ingress-nginx"
  namespace        = "ingress-nginx"
  create_namespace = true
  repository       = "https://kubernetes.github.io/ingress-nginx"
  chart            = "ingress-nginx"

  set {
    name  = "service.type"
    value = "LoadBalancer"
  }
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
    value = "rancher.trentonvanderwert.com"
  }
  set {
    name  = "bootstrapPasswords"
    value = "admin"
  }
  set {
    name  = "ingress.tls.source"
    value = "letsEncrypt"
  }
  set {
    name  = "letsEncrypt.email"
    value = "trenton.vanderwert@gmail.com"
  }
  set {
    name  = "letsEncrypt.ingress.class"
    value = "nginx"
  }

  depends_on = [
    helm_release.ingress_nginx,
    helm_release.cert_manager
  ]
}
