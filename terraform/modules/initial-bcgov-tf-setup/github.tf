# GitHub Repository Management
# This creates GitHub environments and secrets automatically

# Configure the GitHub provider
provider "github" {
  # GitHub token should be set via GITHUB_TOKEN environment variable
  # or through other authentication methods
}

# Split repo_name into owner and repository
locals {
  repo_parts = split("/", var.repo_name)
  repo_owner = local.repo_parts[0]
  repo_name  = local.repo_parts[1]
}

# Get repository information (only if GitHub automation is enabled)
data "github_repository" "repo" {
  count     = var.enable_github_automation ? 1 : 0
  full_name = var.repo_name
}

# Create GitHub environment
resource "github_repository_environment" "deployment_env" {
  count       = var.enable_github_automation ? 1 : 0
  repository  = local.repo_name
  environment = var.target_env

  # Prevent deployments on this environment
  prevent_self_review = false

  # Optional: Add deployment protection rules
  deployment_branch_policy {
    protected_branches     = true
    custom_branch_policies = false
  }
}

# Create environment secrets
resource "github_actions_environment_secret" "aws_deploy_role_arn" {
  count           = var.enable_github_automation ? 1 : 0
  repository      = local.repo_name
  environment     = github_repository_environment.deployment_env[0].environment
  secret_name     = "AWS_DEPLOY_ROLE_ARN"
  plaintext_value = aws_iam_role.github_actions_role.arn
}

resource "github_actions_environment_secret" "aws_license_plate" {
  count           = var.enable_github_automation ? 1 : 0
  repository      = local.repo_name
  environment     = github_repository_environment.deployment_env[0].environment
  secret_name     = "AWS_LICENSE_PLATE"
  plaintext_value = var.aws_license_plate
}

resource "github_actions_environment_secret" "aws_account_number" {
  count           = var.enable_github_automation ? 1 : 0
  repository      = local.repo_name
  environment     = github_repository_environment.deployment_env[0].environment
  secret_name     = "AWS_ACCOUNT_NUMBER"
  plaintext_value = var.aws_account_number
}

resource "github_actions_environment_secret" "aws_region" {
  count           = var.enable_github_automation ? 1 : 0
  repository      = local.repo_name
  environment     = github_repository_environment.deployment_env[0].environment
  secret_name     = "AWS_REGION"
  plaintext_value = var.aws_region
}

resource "github_actions_environment_secret" "ecr_repository" {
  count           = var.enable_github_automation ? 1 : 0
  repository      = local.repo_name
  environment     = github_repository_environment.deployment_env[0].environment
  secret_name     = "ECR_REPOSITORY"
  plaintext_value = aws_ecr_repository.app_repository.name
}

resource "github_actions_environment_secret" "target_env" {
  count           = var.enable_github_automation ? 1 : 0
  repository      = local.repo_name
  environment     = github_repository_environment.deployment_env[0].environment
  secret_name     = "TARGET_ENV"
  plaintext_value = var.target_env
}

resource "github_actions_environment_secret" "terraform_state_bucket" {
  count           = var.enable_github_automation ? 1 : 0
  repository      = local.repo_name
  environment     = github_repository_environment.deployment_env[0].environment
  secret_name     = "TERRAFORM_STATE_BUCKET"
  plaintext_value = aws_s3_bucket.terraform_state.bucket
}

# Optional: Create repository-level secrets (if needed)
resource "github_actions_secret" "ecr_registry" {
  count           = var.enable_github_automation ? 1 : 0
  repository      = local.repo_name
  secret_name     = "ECR_REGISTRY"
  plaintext_value = "${local.account_id}.dkr.ecr.${local.region}.amazonaws.com"
}
