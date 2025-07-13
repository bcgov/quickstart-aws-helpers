# Variables for Terraform deployment setup
# These mirror the inputs from the bash script

variable "repo_name" {
  description = "GitHub repository name in format owner/repo-name"
  type        = string

  validation {
    condition     = can(regex("^[a-zA-Z0-9_.-]+/[a-zA-Z0-9_.-]+$", var.repo_name))
    error_message = "Repository name must be in format 'owner/repo-name'."
  }
}

variable "aws_account_number" {
  description = "AWS account number (12 digits)"
  type        = string

  validation {
    condition     = can(regex("^[0-9]{12}$", var.aws_account_number))
    error_message = "AWS account number must be exactly 12 digits."
  }
}

variable "aws_license_plate" {
  description = "AWS license plate (6 alphanumeric characters)"
  type        = string

  validation {
    condition     = can(regex("^[a-zA-Z0-9]{6}$", var.aws_license_plate))
    error_message = "AWS license plate must be exactly 6 alphanumeric characters."
  }
}

variable "target_env" {
  description = "Target environment (dev, test, prod)"
  type        = string

  validation {
    condition     = contains(["dev", "test", "prod"], var.target_env)
    error_message = "Target environment must be one of: dev, test, prod."
  }
}

variable "aws_region" {
  description = "AWS region for resource deployment"
  type        = string
  default     = "ca-central-1"
}

variable "policy_name" {
  description = "IAM policy name for Terraform deployment"
  type        = string
  default     = "TerraformDeployPolicy"
}

variable "role_name" {
  description = "IAM role name for GitHub Actions"
  type        = string
  default     = "GHA_CI_CD"
}

variable "ecr_repo_name" {
  description = "ECR repository name"
  type        = string
  default     = ""
}

variable "common_tags" {
  description = "Common tags to be applied to all resources"
  type        = map(string)
  default     = {}
}

variable "enable_github_automation" {
  description = "Enable automatic GitHub environment and secrets creation"
  type        = bool
  default     = false
}

# Computed values
locals {
  # Use repo_name as ECR repo name if not specified
  final_ecr_repo_name = var.ecr_repo_name != "" ? var.ecr_repo_name : var.repo_name
}
