terraform {
  required_version = ">= 1.3.5"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.45.0"
    }

    helm = {
      source  = "hashicorp/helm"
      version = "2.7.1"
    }

    http = {
      source  = "hashicorp/http"
      version = "3.2.1"
    }

    tls = {
      source  = "hashicorp/tls"
      version = "4.0.4"
    }
  }

  backend "s3" {
    bucket  = "web-scrapper-states"
    key     = "resources/terraform.tfstate"
    region  = "eu-central-1"
    encrypt = true
  }
}
