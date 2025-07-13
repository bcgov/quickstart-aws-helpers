# IAM Policy and Role for GitHub Actions CI/CD
# This replicates the IAM components from the bash script

# Check if GitHub OIDC provider exists
data "aws_iam_openid_connect_provider" "github" {
  url = "https://token.actions.githubusercontent.com"
}

# Create GitHub OIDC provider if it doesn't exist
resource "aws_iam_openid_connect_provider" "github" {
  count = length(data.aws_iam_openid_connect_provider.github.arn) == 0 ? 1 : 0

  url            = "https://token.actions.githubusercontent.com"
  client_id_list = ["sts.amazonaws.com"]
  thumbprint_list = [
    "6938fd4d98bab03faadb97b34396831e3780aea1",
    "1c58a3a8518e8759bf075b76b750d4f2df264fcd"
  ]

  tags = local.common_tags
}

# IAM Policy Document for Terraform deployment
data "aws_iam_policy_document" "terraform_deploy_policy" {
  # IAM permissions
  statement {
    sid       = "IAM"
    effect    = "Allow"
    actions   = ["iam:*"]
    resources = ["*"]
  }

  # S3 permissions
  statement {
    sid       = "S3"
    effect    = "Allow"
    actions   = ["s3:*"]
    resources = ["*"]
  }

  # CloudFront permissions
  statement {
    sid       = "Cloudfront"
    effect    = "Allow"
    actions   = ["cloudfront:*"]
    resources = ["*"]
  }

  # ECS permissions
  statement {
    sid       = "ecs"
    effect    = "Allow"
    actions   = ["ecs:*"]
    resources = ["*"]
  }

  # ECR permissions
  statement {
    sid       = "ecr"
    effect    = "Allow"
    actions   = ["ecr:*"]
    resources = ["*"]
  }

  # DynamoDB permissions
  statement {
    sid       = "Dynamodb"
    effect    = "Allow"
    actions   = ["dynamodb:*"]
    resources = ["*"]
  }

  # API Gateway permissions
  statement {
    sid       = "APIgateway"
    effect    = "Allow"
    actions   = ["apigateway:*"]
    resources = ["*"]
  }

  # RDS permissions
  statement {
    sid       = "RDS"
    effect    = "Allow"
    actions   = ["rds:*"]
    resources = ["*"]
  }

  # CloudWatch permissions
  statement {
    sid       = "Cloudwatch"
    effect    = "Allow"
    actions   = ["cloudwatch:*"]
    resources = ["*"]
  }

  # EC2 permissions
  statement {
    sid       = "EC2"
    effect    = "Allow"
    actions   = ["ec2:*"]
    resources = ["*"]
  }

  # Auto Scaling permissions
  statement {
    sid       = "Autoscaling"
    effect    = "Allow"
    actions   = ["autoscaling:*"]
    resources = ["*"]
  }

  # KMS permissions
  statement {
    sid       = "KMS"
    effect    = "Allow"
    actions   = ["kms:*"]
    resources = ["*"]
  }

  # Secrets Manager permissions
  statement {
    sid       = "SecretsManager"
    effect    = "Allow"
    actions   = ["secretsmanager:*"]
    resources = ["*"]
  }

  # CloudWatch Logs permissions
  statement {
    sid       = "CloudWatchLogs"
    effect    = "Allow"
    actions   = ["logs:*"]
    resources = ["*"]
  }

  # WAF permissions
  statement {
    sid       = "WAF"
    effect    = "Allow"
    actions   = ["wafv2:*"]
    resources = ["*"]
  }

  # ELB permissions
  statement {
    sid       = "ELB"
    effect    = "Allow"
    actions   = ["elasticloadbalancing:*"]
    resources = ["*"]
  }

  # Application Auto Scaling permissions
  statement {
    sid       = "AppAutoScaling"
    effect    = "Allow"
    actions   = ["application-autoscaling:*"]
    resources = ["*"]
  }
}

# Create IAM policy
resource "aws_iam_policy" "terraform_deploy_policy" {
  name        = var.policy_name
  description = "Policy for GitHub Actions to deploy infrastructure via Terraform"
  policy      = data.aws_iam_policy_document.terraform_deploy_policy.json

  tags = local.common_tags
}

# Trust policy for GitHub OIDC
data "aws_iam_policy_document" "github_trust_policy" {
  statement {
    effect = "Allow"

    principals {
      type = "Federated"
      identifiers = [
        length(data.aws_iam_openid_connect_provider.github.arn) > 0 ?
        data.aws_iam_openid_connect_provider.github.arn :
        aws_iam_openid_connect_provider.github[0].arn
      ]
    }

    actions = ["sts:AssumeRoleWithWebIdentity"]

    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      values   = ["repo:${var.repo_name}:*"]
    }

    condition {
      test     = "ForAllValues:StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }

    condition {
      test     = "ForAllValues:StringEquals"
      variable = "token.actions.githubusercontent.com:iss"
      values   = ["https://token.actions.githubusercontent.com"]
    }
  }
}

# Create IAM role
resource "aws_iam_role" "github_actions_role" {
  name               = var.role_name
  description        = "Role for GitHub Actions to deploy infrastructure via Terraform"
  assume_role_policy = data.aws_iam_policy_document.github_trust_policy.json

  tags = local.common_tags
}

# Attach policy to role
resource "aws_iam_role_policy_attachment" "github_actions_policy_attachment" {
  role       = aws_iam_role.github_actions_role.name
  policy_arn = aws_iam_policy.terraform_deploy_policy.arn
}
