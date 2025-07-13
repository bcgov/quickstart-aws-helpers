# Quickstart AWS Helpers

A centralized repository for reusable GitHub Actions (GHA) and Terraform code to accelerate AWS-based development and deployment workflows.

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
├── terraform/              # Reusable Terraform modules
│   └── modules/            # Infrastructure modules
│       ├── api-gateway/         # API Gateway v2 with VPC integration
│       ├── cloudfront/          # CloudFront distribution management
│       ├── cloudfront-oai/      # CloudFront Origin Access Identity
│       ├── common/              # Shared variables and locals
│       ├── initial-bcgov-tf-setup/  # Initial BC Gov AWS setup
│       ├── networking/          # VPC and subnet configurations
│       ├── s3-cloudfront-logs/  # S3 bucket for CloudFront logs
│       ├── s3-secure-bucket/    # Secure S3 bucket with encryption
│       └── waf/                 # Web Application Firewall v2
├── docs/                   # Documentation (planned)
└── LICENSE                 # Apache License 2.0
```

## 🚀 Getting Started

### Using Terraform Modules

To use the Terraform modules in your infrastructure:

```hcl
# Using the initial BC Gov setup module
module "initial_setup" {
  source = "git::https://github.com/bcgov/quickstart-aws-helpers.git//terraform/modules/initial-bcgov-tf-setup?ref=initial-bcgov-setup/v1.0.0"
  
  repo_name          = "bcgov/your-repo"
  aws_account_number = "123456789012"
  aws_license_plate  = "abc123"
  target_env         = "dev"
  aws_region         = "ca-central-1"
}

# Using the networking module
module "networking" {
  source = "git::https://github.com/bcgov/quickstart-aws-helpers.git//terraform/modules/networking?ref=networking/v1.0.0"
  
  target_env = "dev"
}

# Using the secure S3 bucket module
module "secure_bucket" {
  source = "git::https://github.com/bcgov/quickstart-aws-helpers.git//terraform/modules/s3-secure-bucket?ref=s3-secure-bucket/v1.0.0"
  
  bucket_name        = "my-secure-bucket"
  tags               = local.common_tags
}
```

## 📚 Available Components


### Terraform Modules

#### Core Infrastructure
- [x] **[initial-bcgov-tf-setup](terraform/modules/initial-bcgov-tf-setup/)** - BC Government AWS account initial setup with IAM roles, policies, S3 state bucket, and ECR repository
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

## 🏷️ Versioning

This project uses module-specific [Semantic Versioning](https://semver.org/) with the following format:
- `<module-name>/v<major>.<minor>.<patch>`

### Available Module Versions

#### Core Infrastructure Modules
- `initial-bcgov-tf-setup/v1.0.0` - Initial release with IAM roles, S3 state bucket, and ECR repository
- `common/v1.0.0` - Shared variables and naming conventions for BC Gov standards
- `networking/v1.0.0` - VPC and subnet data sources with standardized naming

#### Application Layer Modules
- `api-gateway/v1.0.0` - API Gateway v2 with VPC link integration
- `cloudfront/v1.0.0` - CloudFront distribution with S3/ALB origins and WAF support
- `cloudfront-oai/v1.0.0` - CloudFront Origin Access Identity for S3 security

#### Storage & Security Modules
- `s3-secure-bucket/v1.0.0` - Hardened S3 bucket with encryption and access controls
- `s3-cloudfront-logs/v1.0.0` - S3 bucket configured for CloudFront logging
- `waf/v1.0.0` - Web Application Firewall v2 with rate limiting and protection rules

For all available versions, see the [tags on this repository](https://github.com/bcgov/quickstart-aws-helpers/tags).

## 📄 License

This project is licensed under the Apache License 2.0 - see the [LICENSE](LICENSE) file for details.

## 🆘 Support

If you encounter any issues or have questions:

1. Check the [documentation](docs/)
2. Search [existing issues](https://github.com/bcgov/quickstart-aws-helpers/issues)
3. Create a [new issue](https://github.com/bcgov/quickstart-aws-helpers/issues/new) with detailed information

## 🔗 Related Resources

- [AWS Documentation](https://docs.aws.amazon.com/)
- [Terraform Documentation](https://www.terraform.io/docs/)
- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [BC Government DevOps Platform](https://developer.gov.bc.ca/docs/default/component/public-cloud-techdocs/aws/)

---
**Maintained by:** BC Government Natural Resource Sector  
