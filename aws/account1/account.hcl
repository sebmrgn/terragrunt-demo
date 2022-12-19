# Set account-wide variables. These are automatically pulled in to configure the remote state bucket in the root
# terragrunt.hcl configuration.
locals {
  aws_account_name   = "non-prod"
  aws_account_id     = "1234567890"
  aws_profile        = "non-prod"
}