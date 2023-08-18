resource "aws_iam_role" "lattice_eks_irsa" {
  name = "lattice-eks-irsa"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Federated = "arn:aws:iam::345796856102:oidc-provider/oidc.eks.us-east-1.amazonaws.com/id/DB3C6E53117795AEB134D71C4FD53332"
        },
        Action = "sts:AssumeRoleWithWebIdentity",
        Condition = {
          StringEquals = {
            "oidc.eks.us-east-1.amazonaws.com/id/DB3C6E53117795AEB134D71C4FD53332:sub" = "system:serviceaccount:external-dns:lattice-eks",
            "oidc.eks.us-east-1.amazonaws.com/id/DB3C6E53117795AEB134D71C4FD53332:aud" = "sts.amazonaws.com"
          }
        }
      }
    ]
  })
}

resource "aws_iam_policy" "vpc_lattice_policy" {
  name        = "LatticePolicy"
  description = "Policy for Route53 operations."

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "vpc-lattice:*",
          "iam:CreateServiceLinkedRole",
          "ec2:DescribeVpcs",
          "ec2:DescribeSubnets"
        ],
        Resource = ["*"]
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lattice_role_attach" {
  role       = aws_iam_role.lattice_eks_irsa.name
  policy_arn = aws_iam_policy.vpc_lattice_policy.arn
}
