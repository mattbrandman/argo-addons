terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.12.0"
    }
  }
}

provider "aws" {
  profile = "duolingosso"
  region  = "us-east-1"
}

resource "aws_iam_role" "external_dns_eks_irsa" {
  name = "external-dns-eks-irsa"
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
            "oidc.eks.us-east-1.amazonaws.com/id/76709DE5227BE515A87A2A4A50D3DB11:sub" = "system:serviceaccount:kube-system:aws-load-balancer-controller-eks",
            "oidc.eks.us-east-1.amazonaws.com/id/DB3C6E53117795AEB134D71C4FD53332:aud" = "sts.amazonaws.com"
          }
        }
      }
    ]
  })
}


resource "aws_iam_policy" "route53_policy" {
  name        = "Route53Policy"
  description = "Policy for Route53 operations."

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = ["route53:ChangeResourceRecordSets"],
        Resource = ["arn:aws:route53:::hostedzone/*"]
      },
      {
        Effect = "Allow",
        Action = [
          "route53:ListHostedZones",
          "route53:ListResourceRecordSets",
          "route53:ListTagsForResource"
        ],
        Resource = ["*"]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "eks_role_attach" {
  role       = aws_iam_role.external_dns_eks_irsa.name
  policy_arn = aws_iam_policy.route53_policy.arn
}
