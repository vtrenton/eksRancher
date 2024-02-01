resource "aws_iam_role" "eks_cluster_role" {
  name = var.cluster_iam_role_name

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


resource "aws_iam_policy" "eks_cloudwatch_metrics" {
  name        = var.cloudwatch_iam_role_name
  description = "Policy for EKS worker nodes"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid      = "CloudWatchMetric",
        Effect   = "Allow",
        Action   = [
            "cloudwatch:PutMetricData"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_policy" "eks_elb_perms" {
  name        = var.elb_iam_role_name
  description = "Policy for EKS worker nodes"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid      = "ELBPolicy",
        Effect   = "Allow",
        Action   = [
            "ec2:DescribeAccountAttributes",
            "ec2:DescribeAddresses",
            "ec2:DescribeInternetGateways"
        ]
        Resource = "*"
      }
    ]
  })
}

# Attach required policies to the IAM role
resource "aws_iam_role_policy_attachment" "eks_cluster_policy" {
  role       = aws_iam_role.eks_cluster_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

resource "aws_iam_role_policy_attachment" "eks_vpc_rc" {
  role       = aws_iam_role.eks_cluster_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
}

resource "aws_iam_role_policy_attachment" "eks_cloud_watch" {
  role       = aws_iam_role.eks_cluster_role.name
  policy_arn = aws_iam_policy.eks_cloudwatch_metrics.arn
}

resource "aws_iam_role_policy_attachment" "eks_elb" {
  role       = aws_iam_role.eks_cluster_role.name
  policy_arn = aws_iam_policy.eks_elb_perms.arn
}

