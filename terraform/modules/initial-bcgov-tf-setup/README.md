# Terraform Deployment Setup

This Terraform configuration creates the foundational AWS infrastructure needed for GitHub Actions CI/CD workflows using pure Terraform without any script dependencies.

## What This Creates

1. **IAM Policy**: Comprehensive AWS permissions for Terraform deployment
2. **IAM Role**: GitHub OIDC trust relationship for secure authentication
3. **S3 Bucket**: Terraform remote state storage with versioning and encryption
4. **ECR Repository**: Container registry with lifecycle policies

## Prerequisites

1. **AWS CLI** installed and configured with appropriate permissions
2. **Terraform** CLI installed (version >= 1.0)
3. **AWS Account** with necessary permissions to create IAM roles, policies, S3 buckets, and ECR repositories

**No script dependencies required** - This is pure Terraform configuration that works on any platform.

## Quick Start

1. **Configure your variables** by creating a `terraform.tfvars` file:

```bash
# Copy the example file
cp terraform.tfvars.example terraform.tfvars
```

2. **Edit `terraform.tfvars`** with your specific values:

```hcl
repo_name           = "bcgov/<reponame>"
aws_account_number  = "123456789012"
aws_license_plate   = "abc123"
target_env          = "dev"
aws_region         = "ca-central-1"
```

3. **Deploy the infrastructure**:

```bash
# Initialize Terraform
terraform init

# Review the plan
terraform plan

# Apply the configuration
terraform apply
```

## Idempotent Design

This Terraform configuration is designed to be **idempotent** and safe to run multiple times:

### Features
- **Prevent Destroy**: S3 bucket includes `prevent_destroy` lifecycle rule
- **Ignore Changes**: Resources ignore changes to existing configurations to prevent conflicts
- **Import Support**: Existing resources can be imported into Terraform state

### Working with Existing Resources

If you already have resources created by the bash script or previous runs:

1. **Import existing bucket** (if needed):
```bash
# Replace [license-plate] and [env] with your actual values
terraform import aws_s3_bucket.terraform_state terraform-remote-state-abc123-dev
```

2. **Use the import helper file**:
```bash
# Edit import.tf and uncomment the relevant import blocks
# Update bucket names to match your existing resources
terraform plan -generate-config-out=generated.tf
terraform apply
```

3. **Safe to re-run**: You can safely run `terraform apply` multiple times without conflicts

## Usage

### 1. Configure Variables (Required)

Create your `terraform.tfvars` file from the example:

```bash
cp terraform.tfvars.example terraform.tfvars
```

**Required Variables:**
- `repo_name`: GitHub repository in format `owner/repo-name`
- `aws_account_number`: Your 12-digit AWS account number
- `aws_license_plate`: Your 6-character AWS license plate
- `target_env`: Target environment (`dev`, `test`, or `prod`)

**Optional Variables:**
- `aws_region`: AWS region (default: `ca-central-1`)
- `policy_name`: IAM policy name (default: `TerraformDeployPolicy`)
- `role_name`: IAM role name (default: `GHA_CI_CD`)
- `ecr_repo_name`: ECR repository name (default: uses `repo_name`)

Edit `terraform.tfvars` with your specific values:

```hcl
repo_name           = "bcgov/qs-aws-demo"
aws_account_number  = "123456789012"
aws_license_plate   = "abc123"
target_env          = "dev"
aws_region         = "ca-central-1"

# Optional: Add common tags
common_tags = {
  Owner       = "your-team"
  Project     = "your-project"
  CostCenter  = "your-cost-center"
}
```

### 2. Initialize and Deploy

```bash
# Initialize Terraform
terraform init

# Review the plan
terraform plan

# Apply the configuration
terraform apply
```

### 3. Configure GitHub Secrets

#### Option A: Automatic GitHub Setup (Recommended)

Enable automatic GitHub environment and secrets creation:

1. **Set GitHub token**:
```bash
export GITHUB_TOKEN="your_github_personal_access_token"
```

2. **Enable GitHub automation** in `terraform.tfvars`:
```hcl
enable_github_automation = true
```

3. **Deploy with GitHub automation**:
```bash
terraform apply
```

This will automatically:
- Create the GitHub environment (`dev`, `test`, or `prod`)
- Configure all required environment secrets
- Set up deployment protection rules

#### Option B: Manual GitHub Setup

If you prefer manual setup or GitHub automation is disabled:

Go to: `Repository Settings > Environments > [your-target-env] > Environment secrets`

Add these secrets (values provided in Terraform outputs):

- `AWS_DEPLOY_ROLE_ARN`: IAM role ARN for GitHub Actions
- `AWS_LICENSE_PLATE`: Your AWS license plate
- `AWS_ACCOUNT_NUMBER`: Your AWS account number
- `AWS_REGION`: AWS region
- `ECR_REPOSITORY`: ECR repository name
- `TARGET_ENV`: Target environment
- `TERRAFORM_STATE_BUCKET`: S3 bucket for Terraform state

#### GitHub Personal Access Token Requirements

For GitHub automation, create a Personal Access Token with these permissions:
- **Repository permissions**: `Administration`, `Actions`, `Metadata`, `Secrets`
- **Account permissions**: `None` (for public repos) or `Read` (for private repos)

Create token at: https://github.com/settings/tokens/new

### 4. Update Terraform Backend

Once the S3 bucket is created, you can configure Terraform to use it as a remote backend by adding this to your `main.tf`:

```hcl
terraform {
  backend "s3" {
    bucket = "terraform-remote-state-[license-plate]-[env]"
    key    = "deployment-setup/terraform.tfstate"
    region = "ca-central-1"
  }
}
```

## Outputs

The configuration provides several useful outputs:

- **setup_summary**: Complete summary of all created resources
- **github_secrets_required**: All GitHub secrets that need to be configured
- **terragrunt_environment_variables**: Environment variables for Terragrunt
- **manual_setup_instructions**: Step-by-step instructions for completion

View outputs with:

```bash
terraform output
```

## File Structure

This directory contains the following files:

### Core Terraform Files
- **`main.tf`**: Main Terraform configuration with provider setup and local values
- **`variables.tf`**: Variable definitions with validation rules
- **`iam.tf`**: IAM policy and role configuration for GitHub Actions
- **`s3.tf`**: S3 bucket for Terraform remote state with security configurations
- **`ecr.tf`**: ECR repository with lifecycle policies
- **`outputs.tf`**: Output values for created resources and configuration instructions

### Configuration Files
- **`terraform.tfvars.example`**: Example variables file to copy and customize
- **`.gitignore`**: Git ignore rules for Terraform files
- **`import.tf`**: Helper file for importing existing AWS resources

### Documentation
- **`README.md`**: This documentation file

## Resource Details

### IAM Policy Permissions

The created IAM policy includes comprehensive permissions for:
- IAM (Identity and Access Management)
- S3 (Simple Storage Service)
- CloudFront (Content Delivery Network)
- ECS (Elastic Container Service)
- ECR (Elastic Container Registry)
- DynamoDB (NoSQL Database)
- API Gateway
- RDS (Relational Database Service)
- CloudWatch (Monitoring and Logging)
- EC2 (Virtual Machines)
- Auto Scaling
- KMS (Key Management Service)
- Secrets Manager
- WAF (Web Application Firewall)
- Elastic Load Balancing
- Application Auto Scaling

### S3 Bucket Security

The Terraform state bucket is configured with:
- **Versioning**: Enabled for state history
- **Encryption**: AES256 server-side encryption
- **Public Access Block**: All public access blocked
- **Bucket Policy**: Denies insecure HTTP connections
- **Lifecycle Policy**: Manages old versions (90-day retention)
- **Idempotent Design**: Includes `prevent_destroy` and `ignore_changes` lifecycle rules
- **Import Support**: Can import existing buckets without conflicts

### ECR Repository Features

The container registry includes:
- **Mutable Tags**: Tags can be overwritten
- **Image Scanning**: Automatic security scanning on push
- **Lifecycle Policies**: 
  - Keep only 5 most recent tagged images
  - Delete untagged images after 1 day
- **Repository Policy**: Allows access from GitHub Actions role and ECS tasks

### GitHub OIDC Integration

The IAM role trusts GitHub Actions with conditions:
- Repository-specific access (`repo:owner/repo-name:*`)
- Proper audience (`sts.amazonaws.com`)
- Correct issuer (`https://token.actions.githubusercontent.com`)

## Cleanup

To remove all resources created by this configuration:

```bash
terraform destroy
```

**Note**: This will permanently delete the S3 bucket and all Terraform state files. Make sure you have backups if needed.

## Troubleshooting

### Common Issues

1. **AWS Credentials**: Ensure AWS CLI is configured with sufficient permissions
2. **Region Mismatch**: Verify the AWS region matches your account setup
3. **Resource Conflicts**: Check if resources with the same names already exist
4. **GitHub OIDC Provider**: The configuration automatically creates the OIDC provider if it doesn't exist
5. **Missing terraform.tfvars**: Ensure you've copied and filled out the variables file

### Required Variable Validation

The Terraform configuration includes validation for:
- **repo_name**: Must be in format `owner/repo-name`
- **aws_account_number**: Must be exactly 12 digits
- **aws_license_plate**: Must be exactly 6 alphanumeric characters
- **target_env**: Must be one of `dev`, `test`, or `prod`

### Verification Commands

```bash
# Verify IAM role
aws iam get-role --role-name GHA_CI_CD

# Verify S3 bucket
aws s3 ls s3://terraform-remote-state-[license-plate]-[env]

# Verify ECR repository
aws ecr describe-repositories --repository-names [repo-name]
```

## Security Considerations

- The IAM policy provides broad permissions suitable for infrastructure deployment
- In production, consider implementing least-privilege access principles
- Regularly review and audit the permissions
- Use AWS CloudTrail to monitor API calls
- Consider implementing additional security controls like SCPs (Service Control Policies)
