terraform {
  required_version = ">= 0.14"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.41"
    }

    random = {
      source  = "hashicorp/random"
      version = ">= 3"
    }

    docker = {
      source = "kreuzwerker/docker"
      version = ">= 2.23.1"
    }
  }

  backend "s3" {
    bucket  = "web-scrapper-states"
    key     = "jenkins-and-vpc/terraform.tfstate"
    region  = "eu-central-1"
    encrypt = true
  }
}
