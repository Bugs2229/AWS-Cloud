terraform {
  required_version = ">= 1.5.0"

  required_providers {

    aws = {
      source  = "hashicorp/aws"
      version = "6.18.0"
    }
  }
}

# terraform {
#   backend "s3" {
#     bucket = "terraform-man-up"
#     key    = "man-up-terraform.tfstate"
#     region = "us-east-1"
#     profile = "default"
#   }
# }

provider "aws" {
  # Configuration options

  region  = "us-east-1"
  profile = "default"

  default_tags {
    tags = {
      ManagedBy = "Terraform"
    }
  }
}