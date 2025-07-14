# How To Deploy to AWS using Terraform

## Prerequisites

1. BCGov AWS account/namespace, make sure you have access provided from PO, [follow this link](https://dev.developer.gov.bc.ca/docs/default/component/public-cloud-techdocs/aws/LZA/design-build-deploy/user-management/#managing-security-group-membership)
2. AWS CLI installed.
3. GitHub CLI (optionally installed).

## Execute the bash script for the initial setup for each AWS environment (dev, test, prod)
1. [Login to console via IDIR MFA](https://bcgov.awsapps.com/start/#/?tab=accounts)
2. click on `Access Keys` for the namespace and copy the information and paste it into your bash terminal, then run 
3. It will give you access keys and also the namespace name (6 chars) and account number (12 digits).
3. repeat for each environment.

```bash

# Run the initial setup script directly from GitHub after replacing with your account number namespace name and repo name
curl -sSL https://raw.githubusercontent.com/bcgov/quickstart-aws-helpers/main/.github/scripts/initial-aws-setup.sh | bash -s \
bcgov/<repo_name> \
000000000000 \
abc123 \
prod \
tfdeploypolicyqsawsdemo \
GHA_CI_CD_QS_AWS_DEMO \
bcgov/<repo_name> \
ca-central-1 \
--create-github-secrets
```
