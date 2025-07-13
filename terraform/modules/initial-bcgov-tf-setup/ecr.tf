# ECR Repository with Lifecycle Policies
# This replicates the ECR repository configuration from the bash script

# ECR repository
resource "aws_ecr_repository" "app_repository" {
  name                 = local.final_ecr_repo_name
  image_tag_mutability = "MUTABLE"

  # Enable image scanning on push
  image_scanning_configuration {
    scan_on_push = true
  }

  # Encryption configuration
  encryption_configuration {
    encryption_type = "AES256"
  }

  tags = merge(local.common_tags, {
    Name    = local.final_ecr_repo_name
    Purpose = "container-registry"
  })
}

# ECR lifecycle policy to manage image retention
resource "aws_ecr_lifecycle_policy" "app_repository_lifecycle" {
  repository = aws_ecr_repository.app_repository.name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Keep only 5 most recent tagged images"
        selection = {
          tagStatus      = "tagged"
          tagPatternList = ["*"]
          countType      = "imageCountMoreThan"
          countNumber    = 5
        }
        action = {
          type = "expire"
        }
      },
      {
        rulePriority = 2
        description  = "Delete untagged images older than 1 day"
        selection = {
          tagStatus   = "untagged"
          countType   = "sinceImagePushed"
          countUnit   = "days"
          countNumber = 1
        }
        action = {
          type = "expire"
        }
      }
    ]
  })
}

# ECR repository policy to allow access from the deployment role
data "aws_iam_policy_document" "ecr_repository_policy" {
  statement {
    sid    = "AllowGitHubActionsAccess"
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = [aws_iam_role.github_actions_role.arn]
    }

    actions = [
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage",
      "ecr:BatchCheckLayerAvailability",
      "ecr:PutImage",
      "ecr:InitiateLayerUpload",
      "ecr:UploadLayerPart",
      "ecr:CompleteLayerUpload",
      "ecr:DescribeRepositories",
      "ecr:GetRepositoryPolicy",
      "ecr:ListImages",
      "ecr:DescribeImages",
      "ecr:BatchDeleteImage",
      "ecr:GetLifecyclePolicy",
      "ecr:GetLifecyclePolicyPreview",
      "ecr:ListTagsForResource",
      "ecr:DescribeImageScanFindings"
    ]
  }

  statement {
    sid    = "AllowECSTaskAccess"
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }

    actions = [
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage",
      "ecr:BatchCheckLayerAvailability"
    ]
  }
}

# Apply repository policy
resource "aws_ecr_repository_policy" "app_repository_policy" {
  repository = aws_ecr_repository.app_repository.name
  policy     = data.aws_iam_policy_document.ecr_repository_policy.json
}
