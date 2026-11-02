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

# The trust policy only says who may assume the role (EKS). What the role may do stays in
# its inline policy, which is scoped to this cluster's ARN.
resource "aws_iam_role" "checkout" {
  name = "checkout-cluster"
  assume_role_policy = jsonencode({
    Version   = "2012-10-17"
    Statement = [{ Effect = "Allow", Principal = { Service = "eks.amazonaws.com" }, Action = "sts:AssumeRole" }]
  })
}

resource "aws_eks_cluster" "checkout" {
  name     = "checkout"
  role_arn = aws_iam_role.checkout.arn
  tags = {
    team = "payments"
    service = "checkout"
    env = "production"
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
