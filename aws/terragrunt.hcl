# ---------------------------------------------------------------------------------------------------------------------
# TERRAGRUNT CONFIGURATION
# Terragrunt is a thin wrapper for Terraform that provides extra tools for working with multiple Terraform modules,
# remote state, and locking: https://github.com/gruntwork-io/terragrunt
# ---------------------------------------------------------------------------------------------------------------------

# ---------------------------------------------------------------------------------------------------------------------
# TERRAFORM
# Used to implement helper functions as needed to generate dynamic values.
# ---------------------------------------------------------------------------------------------------------------------
terraform {
  extra_arguments "set_env" {
    commands = ["plan", "apply", "destroy"]
    env_vars = {
      TF_VAR_timestamp = "${timestamp()}"
    }
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# GLOBAL PARAMETERS
# These variables apply to all configurations in this subfolder. These are automatically merged into the child
# `terragrunt.hcl` config via the include block.
# ---------------------------------------------------------------------------------------------------------------------

locals {
  # Automatically load account-level variables
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))

  # Automatically load region-level variables
  region_vars = read_terragrunt_config(find_in_parent_folders("region.hcl"))

  # Automatically load environment-level variables
  environment_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))

  # Extract the variables we need for easy access
  aws_account_name = local.account_vars.locals.aws_account_name
  aws_account_id   = local.account_vars.locals.aws_account_id
  aws_region   = local.region_vars.locals.aws_region
  project_name = "terragrunt-demo"

  # Global variables
  global_vars = {
    tags = {
      "SOURCE_REPO" = "git@github.com:sebmrgn/terragrunt-demo.git",
      "SOURCE_VERSION" = "0.1",
      "SUB_SOURCE_REPO" = "${path_relative_to_include()}",
      "OWNER_GROUP" = "Demo",
      "OWNER_SUB_GROUP" = "DevOps UK",
      "SERVICE_GROUP" = "DevOps Group",
      #"RESOURCE_GROUP" = "COMPUTE",
      "ENVIRONMENT" = "${local.environment_vars.locals.environment}",
      #"DATE_CREATED" = timestamp()
    }
  }
}

# Generate an AWS provider block
generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
provider "aws" {
  region = "${local.aws_region}"

  # Only these AWS Account IDs may be operated on by this template
  allowed_account_ids = ["${local.aws_account_id}"]
}
EOF
}

# Configure Terragrunt to automatically store tfstate files in an S3 bucket
remote_state {
  backend = "s3"
  config = {
    encrypt        = true
    bucket         = "${local.project_name}-terraform-state-${local.aws_account_id}-${local.aws_region}"
    # Dynamic key construction
    key            = "${path_relative_to_include()}/terraform.tfstate"
    region         = local.aws_region
    dynamodb_table = "${local.project_name}-terraform-state-${local.aws_account_id}-${local.aws_region}"
  }
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
}

# Configure root level variables that all resources can inherit. This is especially helpful with multi-account configs
# where terraform_remote_state data sources are placed directly into the modules.
inputs = merge(
  local.account_vars.locals,
  local.region_vars.locals,
  local.environment_vars.locals,
  local.global_vars
)