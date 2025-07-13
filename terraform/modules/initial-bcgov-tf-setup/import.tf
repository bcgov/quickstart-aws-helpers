# Import Configuration for Existing Resources
# Use this file to import existing AWS resources into Terraform state
# 
# To use these import blocks:
# 1. Uncomment the relevant import blocks below
# 2. Update the bucket name to match your actual bucket name
# 3. Run: terraform plan -generate-config-out=generated.tf
# 4. Run: terraform apply
# 5. Comment out or remove the import blocks after successful import

# Uncomment and update the bucket name to import existing S3 bucket
# import {
#   to = aws_s3_bucket.terraform_state
#   id = "terraform-remote-state-[license-plate]-[env]"
# }

# Import S3 bucket versioning configuration
# import {
#   to = aws_s3_bucket_versioning.terraform_state_versioning
#   id = "terraform-remote-state-[license-plate]-[env]"
# }

# Import S3 bucket encryption configuration
# import {
#   to = aws_s3_bucket_server_side_encryption_configuration.terraform_state_encryption
#   id = "terraform-remote-state-[license-plate]-[env]"
# }

# Import S3 bucket public access block
# import {
#   to = aws_s3_bucket_public_access_block.terraform_state_public_access_block
#   id = "terraform-remote-state-[license-plate]-[env]"
# }

# Import S3 bucket policy
# import {
#   to = aws_s3_bucket_policy.terraform_state_bucket_policy
#   id = "terraform-remote-state-[license-plate]-[env]"
# }

# Import S3 bucket lifecycle configuration
# import {
#   to = aws_s3_bucket_lifecycle_configuration.terraform_state_lifecycle
#   id = "terraform-remote-state-[license-plate]-[env]"
# }
