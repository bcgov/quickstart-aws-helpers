# Terraform deployment script that replicates the functionality of aws-initial-pipeline-setup.sh
# This creates the foundational infrastructure needed for GitHub Actions CI/CD workflows

terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
    # GitHub provider is conditionally required based on enable_github_automation variable
    # When using this module, pass the github provider configuration only if needed
  }
}

provider "aws" {
  region = var.aws_region
}

# Data source to get current AWS account information
data "aws_caller_identity" "current" {}

# Local values for resource naming and configuration
locals {
  account_id = data.aws_caller_identity.current.account_id
  region     = var.aws_region

  # Resource names based on inputs
  terraform_state_bucket = "terraform-remote-state-${var.aws_license_plate}-${var.target_env}"

  common_tags = merge(var.common_tags, {
    Environment  = var.target_env
    Project      = var.repo_name
    LicensePlate = var.aws_license_plate
    ManagedBy    = "terraform"
    Purpose      = "github-actions-cicd"
  })
}
