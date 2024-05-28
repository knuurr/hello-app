terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.51.1"
    }
    template = {
      source  = "hashicorp/template"
      version = "2.2.0"
    }
  }

  required_version = ">= 0.13"
}


provider "aws" {
  # Configures AWS as the provider and sets the region
  region = var.aws_region
}
