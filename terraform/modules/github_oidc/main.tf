locals {
  repo_full_name = "${var.github_org}/${var.github_repo}"
  branch_sub     = "repo:${local.repo_full_name}:ref:refs/heads/${var.github_default_branch}"
  pr_sub         = "repo:${local.repo_full_name}:pull_request"
  env_sub        = "repo:${local.repo_full_name}:environment:${var.environment}"
}

resource "aws_iam_openid_connect_provider" "github" {
  url             = "https://token.actions.githubusercontent.com"
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = ["6938fd4d98bab03faadb97b34396831e3780aea1"]

  tags = var.common_tags
}

data "aws_iam_policy_document" "terraform_assume" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.github.arn]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }

    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      values   = [local.branch_sub, local.pr_sub, local.env_sub]
    }
  }
}

data "aws_iam_policy_document" "deploy_assume" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.github.arn]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }

    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      values   = [local.branch_sub, local.env_sub]
    }
  }
}

resource "aws_iam_role" "terraform" {
  name               = "${var.project_name}-${var.environment}-gha-terraform"
  assume_role_policy = data.aws_iam_policy_document.terraform_assume.json
  tags               = var.common_tags
}

resource "aws_iam_role" "deploy" {
  name               = "${var.project_name}-${var.environment}-gha-deploy"
  assume_role_policy = data.aws_iam_policy_document.deploy_assume.json
  tags               = var.common_tags
}

resource "aws_iam_role" "readonly" {
  name               = "${var.project_name}-${var.environment}-gha-readonly"
  assume_role_policy = data.aws_iam_policy_document.terraform_assume.json
  tags               = var.common_tags
}

resource "aws_iam_role_policy_attachment" "terraform_power_user" {
  role       = aws_iam_role.terraform.name
  policy_arn = "arn:aws:iam::aws:policy/PowerUserAccess"
}

resource "aws_iam_role_policy" "terraform_iam" {
  name = "${var.project_name}-${var.environment}-gha-terraform-iam"
  role = aws_iam_role.terraform.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "iam:CreateRole",
        "iam:DeleteRole",
        "iam:UpdateAssumeRolePolicy",
        "iam:PutRolePolicy",
        "iam:DeleteRolePolicy",
        "iam:AttachRolePolicy",
        "iam:DetachRolePolicy",
        "iam:PassRole",
        "iam:GetRole",
        "iam:TagRole",
        "iam:CreateOpenIDConnectProvider",
        "iam:DeleteOpenIDConnectProvider",
        "iam:UpdateOpenIDConnectProviderThumbprint",
        "iam:GetOpenIDConnectProvider",
        "iam:AddClientIDToOpenIDConnectProvider",
        "iam:RemoveClientIDFromOpenIDConnectProvider"
      ]
      Resource = "*"
    }]
  })
}

resource "aws_iam_role_policy" "deploy" {
  name = "${var.project_name}-${var.environment}-gha-deploy"
  role = aws_iam_role.deploy.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["ecr:GetAuthorizationToken"]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "ecr:BatchCheckLayerAvailability",
          "ecr:CompleteLayerUpload",
          "ecr:InitiateLayerUpload",
          "ecr:PutImage",
          "ecr:UploadLayerPart",
          "ecr:BatchGetImage",
          "ecr:DescribeRepositories"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "ecs:DescribeServices",
          "ecs:DescribeTaskDefinition",
          "ecs:RegisterTaskDefinition",
          "ecs:UpdateService",
          "ecs:DescribeClusters",
          "ecs:ListTasks"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = ["iam:PassRole"]
        Resource = [
          var.task_execution_role_arn,
          var.task_role_arn
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "readonly_audit" {
  role       = aws_iam_role.readonly.name
  policy_arn = "arn:aws:iam::aws:policy/SecurityAudit"
}

resource "aws_iam_role_policy" "readonly_extra" {
  name = "${var.project_name}-${var.environment}-gha-readonly"
  role = aws_iam_role.readonly.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "logs:DescribeLogGroups",
        "logs:DescribeLogStreams",
        "logs:GetLogEvents",
        "logs:FilterLogEvents",
        "cloudwatch:GetDashboard",
        "cloudwatch:ListDashboards",
        "s3:ListBucket",
        "s3:GetObject",
        "dynamodb:DescribeTable",
        "dynamodb:GetItem",
        "dynamodb:Query",
        "ssm:GetParameter",
        "ssm:GetParameters",
        "secretsmanager:DescribeSecret"
      ]
      Resource = "*"
    }]
  })
}
