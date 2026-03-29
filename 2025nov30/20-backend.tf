terraform {
    backend "s3" {
        bucket = "man-up-terraform-backend"
        key    = "state/113025/terraform.tfstate"
        region = "us-east-1"
    }
}