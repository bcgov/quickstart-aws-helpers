# Outputs for the Terraform deployment setup
# These mirror the information displayed by the bash script

output "setup_summary" {
  description = "Summary of created resources"
  value = {
    s3_bucket           = local.terraform_state_bucket
    iam_policy_name     = aws_iam_policy.terraform_deploy_policy.name
    iam_policy_arn      = aws_iam_policy.terraform_deploy_policy.arn
    iam_role_name       = aws_iam_role.github_actions_role.name
    iam_role_arn        = aws_iam_role.github_actions_role.arn
    ecr_repository_name = aws_ecr_repository.app_repository.name
    ecr_repository_url  = aws_ecr_repository.app_repository.repository_url
    aws_account_number  = local.account_id
    aws_region          = local.region
    target_environment  = var.target_env
    aws_license_plate   = var.aws_license_plate
  }
}

# Individual outputs for easy reference
output "terraform_state_bucket" {
  description = "S3 bucket for Terraform remote state"
  value       = local.terraform_state_bucket
}

output "github_actions_role_arn" {
  description = "ARN of the IAM role for GitHub Actions"
  value       = aws_iam_role.github_actions_role.arn
}

output "ecr_repository_url" {
  description = "URL of the ECR repository"
  value       = aws_ecr_repository.app_repository.repository_url
}

output "aws_account_number" {
  description = "AWS account number"
  value       = local.account_id
}

output "aws_region" {
  description = "AWS region"
  value       = local.region
}

# GitHub secrets that need to be configured
output "github_secrets_required" {
  description = "GitHub secrets that need to be configured for the environment"
  value = {
    AWS_DEPLOY_ROLE_ARN = aws_iam_role.github_actions_role.arn
    AWS_LICENSE_PLATE   = var.aws_license_plate
    AWS_ACCOUNT_NUMBER  = local.account_id
    AWS_REGION          = local.region
    ECR_REPOSITORY      = aws_ecr_repository.app_repository.name
    TARGET_ENV          = var.target_env
  }
}

# Terragrunt environment variables
output "terragrunt_environment_variables" {
  description = "Environment variables for Terragrunt configuration"
  value = {
    target_env        = var.target_env
    aws_license_plate = var.aws_license_plate
    app_env           = "<your-app-environment>"
    api_image         = "<your-api-docker-image>"
    repo_name         = var.repo_name
    ecr_repository    = aws_ecr_repository.app_repository.name
    stack_prefix      = "<your-application-prefix>"
  }
}

# Instructions for manual setup
output "manual_setup_instructions" {
  description = "Instructions for completing the setup"
  value = {
    github_environment_setup = var.enable_github_automation ? "GitHub environment '${var.target_env}' created automatically" : "Create GitHub environment '${var.target_env}' in your repository"
    github_secrets_path      = "Repository Settings > Environments > ${var.target_env} > Environment secrets"
    github_automation_status = var.enable_github_automation ? "✅ GitHub automation ENABLED" : "❌ GitHub automation DISABLED - set enable_github_automation=true to automate"
    github_token_required    = var.enable_github_automation ? "⚠️  GITHUB_TOKEN environment variable must be set" : "Not required (manual setup)"
    ecr_registry             = "${local.account_id}.dkr.ecr.${local.region}.amazonaws.com/${aws_ecr_repository.app_repository.name}"
    terraform_backend_config = {
      bucket = local.terraform_state_bucket
      key    = "terraform.tfstate"
      region = local.region
    }
  }
}

# GitHub automation status
output "github_automation_status" {
  description = "Status of GitHub automation"
  value = {
    enabled               = var.enable_github_automation
    environment_created   = var.enable_github_automation ? "✅ Environment '${var.target_env}' created" : "❌ Manual setup required"
    secrets_created       = var.enable_github_automation ? "✅ All secrets configured automatically" : "❌ Manual secrets configuration required"
    github_token_required = var.enable_github_automation ? "⚠️  GITHUB_TOKEN environment variable required" : "Not required"
  }
}
