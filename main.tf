terraform {
    required_providers {
        aws     = {
            source = "hashicorp/aws"
        }
        helm    = {
            source = "hashicorp/helm"
        }
        rancher = {
            source = "rancher/rancher2"
        }
    }
}
