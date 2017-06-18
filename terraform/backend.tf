# This setups the s3 backend. This setting along with the ones in terragrunt
# are required for this to work properly.
provider "aws" {
  region = "${var.aws_region}"
}

terraform {
  backend "s3" {}
}
