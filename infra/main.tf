# Checkout service infrastructure: an EKS cluster and the IAM role it runs as.
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "eu-west-1"
}

# "Least privilege": the role's trust policy is now built from its inline policy, and the
# inline policy is scoped to this cluster's ARN. Together they form a dependency cycle.
resource "aws_iam_role" "checkout" {
  name               = "checkout-cluster"
  assume_role_policy = aws_iam_role_policy.checkout.policy
}

resource "aws_eks_cluster" "checkout" {
  name     = "checkout"
  role_arn = aws_iam_role.checkout.arn
  tags = {
    team = "payments"
  }
  vpc_config {
    subnet_ids = ["subnet-0a1b2c3d4e5f60718", "subnet-0f1e2d3c4b5a69788"]
  }
}

resource "aws_iam_role_policy" "checkout" {
  name   = "checkout-access"
  role   = aws_iam_role.checkout.id
  policy = jsonencode({ Version = "2012-10-17", Statement = [{ Effect = "Allow", Action = "eks:DescribeCluster", Resource = aws_eks_cluster.checkout.arn }] })
}
