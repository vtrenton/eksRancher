variable "aws_region" {
  type        = string
  default     = "us-east-1"
  description = "Region used to create cluster"
}

variable "cluster_name" {
  type        = string
  default     = "RancherMC"
  description = "Name of the Rancher cluster"
}

variable "cluster_version" {
  type        = string
  default     = "1.27"
  description = "Kubernetes version of EKS cluster"
}

variable "instance_size" {
  type        = string
  default     = "t3.medium"
  description = "Instance of EC2 Workers"
}

variable "node_group_name" {
  type        = string
  default     = "rancher-node-group"
  description = "Name of the EKS node group"
}

variable "rancher_hostname" {
  type        = string
  default     = "rancher.trentonvanderwert.com"
  description = "The hostname set on the ingress of rancher"
}

variable "bootstrapPassword" {
  type        = string
  default     = "admin"
  description = "Default password for initial Rancher set-up"
}

variable "letsEncryptEmail" {
  type        = string
  default     = "trenton.vanderwert@gmail.com"
  description = "Email used for letsEncrypt"
}

variable "vpc_cidr" {
  type        = string
  default     = "10.0.0.0/16"
  description = "The network assigned to the VPC"
}

variable "az_a" {
  type        = string
  default     = "us-east-1a"
  description = "Availibilty Zone for Subnet A"
}

variable "az_b" {
  type        = string
  default     = "us-east-1b"
  description = "Availibility Zone for Subnet B"
}

variable "az_subnet" {
  type        = number
  default     = 8
  description = "Number of additional bits needed to get from the VPC cidr to subnet"
}

variable "worker_iam_role_name" {
  type        = string
  default     = "eksRancherWorker"
  description = "Name of the Worker Node iam role"
}

variable "cluster_iam_role_name" {
  type        = string
  default     = "eksRancherCluster"
  description = "Name of the Worker Node iam role"
}

variable "cloudwatch_iam_role_name" {
  type        = string
  default     = "eksCloudwatch"
  description = "Name of the Worker Node iam role"
}

variable "elb_iam_role_name" {
  type        = string
  default     = "eksELBPolicy"
  description = "Name of the Worker Node iam role"
}

