# Set common variables for the region. This is automatically pulled in in the root terragrunt.hcl configuration to
# configure the remote state bucket and pass forward to the child modules as inputs.

locals {
  aws_region = "eu-west-2"
  azs        = ["eu-west-2a", "eu-west-2b", "eu-west-2c"]
}