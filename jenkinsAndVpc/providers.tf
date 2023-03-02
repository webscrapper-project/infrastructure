provider "aws" {
  region     = var.aws_region
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}

provider "docker" {
  host = "unix:///var/run/docker.sock"
  registry_auth {
    address = split("//", module.ecr.ecr-token.proxy_endpoint)[1]
    username = module.ecr.ecr-token.user_name
    password = module.ecr.ecr-token.password
  }
}
