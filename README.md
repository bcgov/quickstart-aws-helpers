# Quickstart AWS Helpers

A centralized repository for reusable GitHub Actions (GHA), Terraform code, and scripts to accelerate AWS-based development and deployment workflows.

## 🎯 Purpose

This repository serves as a collection of battle-tested, reusable components that can be leveraged across multiple projects to:

- **Standardize** AWS deployment patterns
- **Accelerate** development workflows
- **Ensure** consistent infrastructure practices
- **Reduce** code duplication across projects
- **Improve** maintainability and reliability

## 📁 Repository Structure

```
quickstart-aws-helpers/
├── .github/
│   └── scripts/            # Setup and utility scripts
│       └── initial-aws-setup.sh    # Initial BC Gov AWS setup script
├── terraform/              # Reusable Terraform modules
│   └── modules/            # Infrastructure modules
│       ├── api-gateway/         # API Gateway v2 with VPC integration
│       ├── cloudfront/          # CloudFront distribution management
│       ├── cloudfront-oai/      # CloudFront Origin Access Identity
│       ├── common/              # Shared variables and locals
│       ├── networking/          # VPC and subnet configurations
│       ├── s3-cloudfront-logs/  # S3 bucket for CloudFront logs
│       ├── s3-secure-bucket/    # Secure S3 bucket with encryption
│       └── waf/                 # Web Application Firewall v2
└── LICENSE                 # Apache License 2.0
```

## 🚀 Getting Started

### Using Terraform Modules

To use the Terraform modules in your infrastructure:

```hcl
# Using the networking module
module "networking" {
  source = "git::https://github.com/bcgov/quickstart-aws-helpers.git//terraform/modules/networking?ref=v0.0.5"
  
  target_env = "dev"
}

# Using the secure S3 bucket module
module "secure_bucket" {
  source = "git::https://github.com/bcgov/quickstart-aws-helpers.git//terraform/modules/s3-secure-bucket?ref=v0.0.5"
  
  bucket_name        = "my-secure-bucket"
  tags               = local.common_tags
}
```

## 📚 Available Components


### GitHub Actions
- [x] **[AWS-Deploy](./AWS-DEPLOY.md)** - Guide to setup GHA CI/CD

### Local profiles
- [x] **[AWS-SSO](./AWS-SSO-Profiles.md)** - Centralized AWS SSO authentication workflow for secure access across multiple environments

### Setup Scripts
- [x] **[initial-bcgov-setup.sh](.github/scripts/initial-aws-setup.sh)** - BC Government AWS account initial setup script for IAM roles, policies, S3 state bucket, and ECR repository

### Terraform Modules
### Terraform Modules
#### Core Infrastructure
- [x] **[common](terraform/modules/common/)** - Shared variables, locals, and standardized naming conventions across modules
- [x] **[networking](terraform/modules/networking/)** - VPC and subnet data sources with standardized BC Gov naming patterns

#### Application Layer
- [x] **[api-gateway](terraform/modules/api-gateway/)** - API Gateway v2 with VPC link integration for private subnet connectivity
- [x] **[cloudfront](terraform/modules/cloudfront/)** - CloudFront distribution with S3 and ALB origin support, logging, and WAF integration
- [x] **[cloudfront-oai](terraform/modules/cloudfront-oai/)** - CloudFront Origin Access Identity for secure S3 access

#### Storage & Security
- [x] **[s3-secure-bucket](terraform/modules/s3-secure-bucket/)** - Hardened S3 bucket with encryption, public access blocking, and lifecycle policies
- [x] **[s3-cloudfront-logs](terraform/modules/s3-cloudfront-logs/)** - S3 bucket specifically configured for CloudFront access logs
- [x] **[waf](terraform/modules/waf/)** - Web Application Firewall v2 with rate limiting, geo-blocking, and common attack protection


## 📄 License

This project is licensed under the Apache License 2.0 - see the [LICENSE](LICENSE) file for details.

## 🆘 Support

If you encounter any issues or have questions:

1. Search [existing issues](https://github.com/bcgov/quickstart-aws-helpers/issues)
2. Create a [new issue](https://github.com/bcgov/quickstart-aws-helpers/issues/new) with detailed information

## 🔗 Related Resources

- [AWS Documentation](https://docs.aws.amazon.com/)
- [Terraform Documentation](https://www.terraform.io/docs/)
- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [BC Government DevOps Platform](https://developer.gov.bc.ca/docs/default/component/public-cloud-techdocs/aws/)

---
**Maintained by:** BC Government Natural Resource Sector