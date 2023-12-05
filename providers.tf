terraform {
  required_version = "~> 1.0"

  required_providers {
    aws = "~> 5.0"
  }
}

provider "aws" {
  profile = var.profile
  region  = var.region
}
