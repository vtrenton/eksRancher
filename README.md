# Install Rancher on an EKS cluster!

This is a demo of a very simple deployment of Rancher on EKS! You can use this as you please to set up your own lab and production environments (I dont provide support of any kind). Obviously this doesn't fit every use case ever. But this should be a good start if you are looking to get up and running with Rancher in EKS.

## Varibles - Use them
I created a `terraform.tfvars` file so you can quickly swap out my setttings for your own. This isn't all encompansing and I took some liberty to just have some hard coded defaults. If you don't like my defaults - its not hard to change. I wouldn't mind a PR to make things more flexible but It really isn't my priority.

## Note about letsEncrypt
By default I chose to use letsEncrypt as my cert provider because its the ez mode way of getting certs for a public facing service. If you hate being secure or want to add your own custom certs you're gonna need to manually add them.

## Note about default ingress
it's ingress-nginx - the default kubernetes one - don't like it? the fork button's on the top of the page. Might maybe possibly use gateway-api in the future if EKS GA's it: https://gateway-api.sigs.k8s.io/implementations/#amazon-elastic-kubernetes-service

## Note about EKS version
Yea it's probably pretty old but I need to keep in the spirit of the Rancher Support Matrix: https://www.suse.com/suse-rancher/support-matrix/all-supported-versions

## Note about Rancher Version
Its the latest stable version from the stable repo (hardcoded) - you can add the `--set version=v2.8.1` by adding in a block to specify the Rancher Version by creating a block in the `rancher` `helm_release` block in `rancher.tf`:
```
set {
    name  = "version"
    value = "2.8.1"
}
```
But just know if that you should always try to be on the latest availible Rancher Prime Release. If you are trying to use an osbolete version of Rancher. You should seriously reconsider if this is the best tool for the job.


