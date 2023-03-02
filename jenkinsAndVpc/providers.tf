provider "aws" {
  region     = var.aws_region
}

provider "docker" {
  host = "unix:///var/run/docker.sock"
  registry_auth {
    address = split("//", module.ecr.ecr-token.proxy_endpoint)[1]
    username = module.ecr.ecr-token.user_name
    password = module.ecr.ecr-token.password
  }
}
