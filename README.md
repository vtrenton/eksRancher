# Install Rancher on an EKS cluster!

This is a demo of a very simple deployment of Rancher on EKS! You can use this as you please to set up your own lab and production environments (I dont provide support of any kind). Obviously this doesn't fit every use case ever. But this should be a good start if you are looking to get up and running with Rancher in EKS.

![eksRancherDiagram](https://github.com/vtrenton/eksRancher/assets/85969349/ea65521e-746e-41ad-9b85-96b5dd24f98d)

## Varibles - Use them
I created a `terraform.tfvars` file so you can quickly swap out my setttings for your own. This isn't all encompansing and I took some liberty to just have some hard coded defaults. If you don't like my defaults - its not hard to change. I wouldn't mind a PR to make things more flexible but It really isn't my priority.

## Note about letsEncrypt
By default I chose to use letsEncrypt as my cert provider because its the ez mode way of getting certs for a public facing service. If you hate being secure or want to add your own custom certs you're gonna need to manually add them.

## Note about default ingress
it's ingress-nginx - the default kubernetes one - don't like it? the fork button's on the top of the page. Might maybe possibly use gateway-api in the future if EKS GA's it: https://gateway-api.sigs.k8s.io/implementations/#amazon-elastic-kubernetes-service

## Note about EKS version
Yea it's probably pretty old but I need to keep in the spirit of the Rancher Support Matrix: https://www.suse.com/suse-rancher/support-matrix/all-supported-versions

## Note about AMI
if you don't specify one - Amazon picks the purpose built AMI for EKS called bottlerocket and picks the specific image for your version. I personally think the Amazon defaults are the best for an EKS cluster. So stick with that. On the other hand if you need to change to your shiney sexy super awesome Linux AMI with all the bells and whistles of the enterprise you can add an AMI in the `rancher_cluster` `aws_eks_cluster` resource in the `eks.tf` file. For example: 
```
resource "aws_eks_cluster" "rancher_cluster" {
  name = var.cluster_name
  ami  = ami-05efd9e66ddc3cf4b
  // rest of the config
}
```

## Note about Rancher Version
Its the latest stable version from the stable repo (hardcoded) - you can add the `--set version=v2.8.1` by adding in a block to specify the Rancher Version by creating a block in the `rancher` `helm_release` block in `rancher.tf`:
```
set {
    name  = "version"
    value = "2.8.1"
}
```
But just know if that you should always try to be on the latest availible Rancher Prime Release. If you are trying to use an osbolete version of Rancher. You should seriously reconsider if this is the best tool for the job.

# Usage

Doesn't get much easier... open this directory and
```
tofu apply
```
Did I test with Terraform? Nope.

Will I? Nope.

You should switch to OpenTofu if you haven't :)

## Utils
By default, files will be dumped to the `out` directory (the empty one with a .gitignore) this creates an ssh key so you can ssh into the worker nodes in a secure way. This is a preshared key That your local machine and KMS will have. Also, once the cluster is created a kubeconfig will be dropped in there as well. the helm provider uses this kubeconfig to install ingres-nginx, cert-manager and Rancher.
