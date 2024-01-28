# Give proper cluster roles as defined by:
# https://ranchermanager.docs.rancher.com/how-to-guides/new-user-guides/kubernetes-clusters-in-rancher-setup/set-up-clusters-from-hosted-kubernetes-providers/eks

resource "aws_iam_role" "eks_cluster_role" {
  name = "eks-cluster-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "eks.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

# IAM role for EKS Worker Nodes
resource "aws_iam_role" "eks_worker_role" {
  name = "eks-worker-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "ec2.amazonaws.com"
        },
      },
    ]
  })
}

resource "aws_iam_policy" "eks_worker_node_policy" {
  name        = "eksWorkerPolicy"
  description = "Policy for EKS worker nodes"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid      = "EC2Permissions",
        Effect   = "Allow",
        Action   = [
            "ec2:RunInstances",
            "ec2:RevokeSecurityGroupIngress",
            "ec2:RevokeSecurityGroupEgress",
            "ec2:DescribeInstanceTypes",
            "ec2:DescribeRegions",
            "ec2:DescribeVpcs",
            "ec2:DescribeTags",
            "ec2:DescribeSubnets",
            "ec2:DescribeSecurityGroups",
            "ec2:DescribeRouteTables",
            "ec2:DescribeLaunchTemplateVersions",
            "ec2:DescribeLaunchTemplates",
            "ec2:DescribeKeyPairs",
            "ec2:DescribeInternetGateways",
            "ec2:DescribeImages",
            "ec2:DescribeAvailabilityZones",
            "ec2:DescribeAccountAttributes",
            "ec2:DeleteTags",
            "ec2:DeleteLaunchTemplate",
            "ec2:DeleteSecurityGroup",
            "ec2:DeleteKeyPair",
            "ec2:CreateTags",
            "ec2:CreateSecurityGroup",
            "ec2:CreateLaunchTemplateVersion",
            "ec2:CreateLaunchTemplate",
            "ec2:CreateKeyPair",
            "ec2:AuthorizeSecurityGroupIngress",
            "ec2:AuthorizeSecurityGroupEgress" 
        ],
        Resource = "*"
      },
      {
        Sid      = "EKSPermissions",
        Effect   = "Allow",
        Action   = [
            "eks:UpdateNodegroupVersion",
            "eks:UpdateNodegroupConfig",
            "eks:UpdateClusterVersion",
            "eks:UpdateClusterConfig",
            "eks:UntagResource",
            "eks:TagResource",
            "eks:ListUpdates",
            "eks:ListTagsForResource",
            "eks:ListNodegroups",
            "eks:ListFargateProfiles",
            "eks:ListClusters",
            "eks:DescribeUpdate",
            "eks:DescribeNodegroup",
            "eks:DescribeFargateProfile",
            "eks:DescribeCluster",
            "eks:DeleteNodegroup",
            "eks:DeleteFargateProfile",
            "eks:DeleteCluster",
            "eks:CreateNodegroup",
            "eks:CreateFargateProfile",
            "eks:CreateCluster"
        ],
        Resource = "*"
      },
      {
        Sid      = "IAMPermissions",
        Effect   = "Allow",
        Action   = [
            "iam:PassRole",
            "iam:ListRoles",
            "iam:ListRoleTags",
            "iam:ListInstanceProfilesForRole",
            "iam:ListInstanceProfiles",
            "iam:ListAttachedRolePolicies",
            "iam:GetRole",
            "iam:GetInstanceProfile",
            "iam:DetachRolePolicy",
            "iam:DeleteRole",
            "iam:CreateRole",
            "iam:AttachRolePolicy"
        ],
        Resource = "*"
      },
      {
        Sid      = "CloudFormationPermissions",
        Effect   = "Allow",
        Action   = [
            "cloudformation:ListStacks",
            "cloudformation:ListStackResources",
            "cloudformation:DescribeStacks",
            "cloudformation:DescribeStackResources",
            "cloudformation:DescribeStackResource",
            "cloudformation:DeleteStack",
            "cloudformation:CreateStackSet",
            "cloudformation:CreateStack"
        ],
        Resource = "*"
      },
      {
        Sid      = "KMSPermissions",
        Effect   = "Allow",
        Action   = "kms:ListKeys",
        Resource = "*"
      }
    ]
  })
}

# Attach required policies to the IAM role
resource "aws_iam_role_policy_attachment" "eks_worker_node_policy_attachment" {
  role       = aws_iam_role.eks_cluster_role.name
  policy_arn = aws_iam_policy.eks_worker_node_policy.arn
}

resource "aws_iam_role_policy_attachment" "eks_worker_policy" {
  role       = aws_iam_role.eks_worker_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_role_policy_attachment" "eks_cni_policy" {
  role       = aws_iam_role.eks_worker_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

resource "aws_iam_instance_profile" "eks_worker_instance_profile" {
  name = "eks-worker-instance-profile"
  role = aws_iam_role.eks_worker_role.name
}
